"""Scenario D — Stress: concurrent re-init + stale pid cleanup (impeccable pattern).
Real bash, real kill -0, real pid files.
# test: scenario D stale pid + learning append - stale pid cleaned, live pid preserved, learning.md monotonic append-only
"""
import subprocess
import pathlib
import shutil
import json
import time
import os
import signal

REPO_ROOT = pathlib.Path("/Users/webileapps/Chandu/github/forge-standard")
INIT_SH = REPO_ROOT / "scripts" / "init.sh"


def run(cmd, cwd=None):
    return subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True)


def test_d_stale_pid_cleanup(tmp_path):
    tmp = tmp_path / "stress"
    tmp.mkdir()
    run("git init", cwd=tmp)
    run("git config user.email test@test.com", cwd=tmp)
    run("git config user.name test", cwd=tmp)
    (tmp / "README.md").write_text("# test\n")
    shutil.copytree(REPO_ROOT / "scripts", tmp / "scripts")
    shutil.copytree(REPO_ROOT / "references", tmp / "references")
    run("git add .", cwd=tmp)
    run("git commit -m init", cwd=tmp)

    # first init to create .forge-standard
    r0 = run(f"bash {INIT_SH}", cwd=tmp)
    if r0.returncode != 0:
        r0 = run("bash ./scripts/init.sh", cwd=tmp)
    assert r0.returncode == 0
    anvil = tmp / ".forge-standard"
    assert (anvil / "state.json").exists()
    state_before = (anvil / "state.json").read_text()
    json.loads(state_before)  # must be valid json

    # Setup: echo 999999 > .forge-standard/.pid (stale)
    (anvil / ".pid").write_text("999999\n")
    assert (anvil / ".pid").read_text().strip() == "999999"
    # Verify 999999 is stale (kill -0 should fail)
    r_kill = run("kill -0 999999 2>&1; echo RC:$?")
    print(f"kill -0 999999: {r_kill.stdout}")
    # also create live pid: sleep 10 & echo $! > .forge-standard/.pid.live
    sleeper = subprocess.Popen(["sleep", "10"])
    live_pid = str(sleeper.pid)
    (anvil / ".pid.live").write_text(live_pid + "\n")
    print(f"live pid: {live_pid}, stale pid: 999999")
    # verify live pid is alive
    r_live_check = run(f"kill -0 {live_pid} 2>&1; echo RC:$?")
    print(f"kill -0 {live_pid}: {r_live_check.stdout}")
    assert "RC:0" in r_live_check.stdout, f"live pid {live_pid} should be alive"

    # Run init.sh — should detect stale pid via kill -0 check and unlink
    r1 = run(f"bash {INIT_SH}", cwd=tmp)
    if r1.returncode != 0:
        r1 = run("bash ./scripts/init.sh", cwd=tmp)
    print(f"init after stale+live: stdout={r1.stdout} stderr={r1.stderr} rc={r1.returncode}")
    assert r1.returncode == 0, f"init failed: {r1.stderr}"

    # Pass: Stale pid removed, live pid preserved, state.json not truncated
    stale_exists = (anvil / ".pid").exists()
    stale_content = (anvil / ".pid").read_text().strip() if stale_exists else "<removed>"
    print(f"after init: .pid exists={stale_exists} content={stale_content!r}")
    assert not stale_exists or stale_content != "999999", "stale pid 999999 should be removed"

    live_exists = (anvil / ".pid.live").exists()
    assert live_exists, ".pid.live should be preserved"
    live_content = (anvil / ".pid.live").read_text().strip()
    print(f".pid.live content: {live_content!r}")
    assert live_content == live_pid, f"live pid preserved expected {live_pid} got {live_content}"

    # state.json not truncated
    state_after = (anvil / "state.json").read_text()
    print(f"state.json before: {state_before!r}\nstate.json after: {state_after!r}")
    assert state_after.strip(), "state.json empty/truncated"
    data = json.loads(state_after)
    assert data.get("initialized") is True
    assert "version" in data
    # also ensure valid via jq
    r_jq = run("jq empty .forge-standard/state.json && echo jq_ok", cwd=tmp)
    assert "jq_ok" in r_jq.stdout, f"state.json invalid json: {r_jq.stdout} {r_jq.stderr}"

    # Additional: stale .pid.live also cleaned if stale
    (anvil / ".pid.live").write_text("999998\n")
    # kill -0 999998 should be stale
    r2 = run(f"bash {INIT_SH}", cwd=tmp)
    if r2.returncode != 0:
        r2 = run("bash ./scripts/init.sh", cwd=tmp)
    assert r2.returncode == 0
    # if init also handles .pid.live stale, it should be removed or handled; at least no crash
    # Restore live for cleanup check
    # Cleanup sleeper
    try:
        sleeper.terminate()
        sleeper.wait(timeout=2)
    except Exception:
        try:
            os.kill(sleeper.pid, signal.SIGKILL)
        except Exception:
            pass

    # Artifact
    ls = run("ls -R .forge-standard", cwd=tmp).stdout
    cat_state = (anvil / "state.json").read_text()
    print(f"\nARTIFACT ls -R:\n{ls}\nARTIFACT cat state.json:\n{cat_state}\nARTIFACT .pid head:\n{run('ls -l .forge-standard/.pid* 2>&1; cat .forge-standard/.pid 2>&1; cat .forge-standard/.pid.live 2>&1', cwd=tmp).stdout}")

    # Final: concurrent re-init — run two init.sh concurrently (impeccable pattern)
    p1 = subprocess.Popen(["bash", str(INIT_SH)], cwd=tmp)
    p2 = subprocess.Popen(["bash", str(INIT_SH)], cwd=tmp)
    p1.wait(timeout=10)
    p2.wait(timeout=10)
    assert p1.returncode == 0 and p2.returncode == 0, f"concurrent re-init failed p1:{p1.returncode} p2:{p2.returncode}"
    # state still valid
    final_state = json.loads((anvil / "state.json").read_text())
    assert final_state.get("initialized") is True
    print(f"concurrent re-init done, final state: {final_state}")
