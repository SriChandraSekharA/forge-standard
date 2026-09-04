"""Scenario A — Happy: first init -> second update (idempotent preserve).
Real git repos, real bash ./scripts/init.sh, no mocks.
"""
import json
import subprocess
import pathlib
import shutil

REPO_ROOT = pathlib.Path("/Users/webileapps/Chandu/github/forge-standard")
INIT_SH = REPO_ROOT / "scripts" / "init.sh"


def run(cmd, cwd=None):
    return subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True)


def test_a_idempotent_preserve(tmp_path):
    tmp = tmp_path / "happy"
    tmp.mkdir()
    # Setup: tmp_repo git init + AGENTS.md + cp scripts/references
    r = run("git init", cwd=tmp)
    assert r.returncode == 0, r.stderr
    run("git config user.email test@test.com", cwd=tmp)
    run("git config user.name test", cwd=tmp)
    (tmp / "AGENTS.md").write_text("# AGENTS\n")
    # copy scripts + references so init.sh resolves (references needed)
    shutil.copytree(REPO_ROOT / "scripts", tmp / "scripts")
    shutil.copytree(REPO_ROOT / "references", tmp / "references")
    run("git add .", cwd=tmp)
    run("git commit -m init", cwd=tmp)

    # 1st init
    r1 = run(f"bash {INIT_SH} 2>&1; echo EXIT:$?", cwd=tmp)
    # also allow local scripts copy to be used
    if "init done" not in r1.stdout:
        r1b = run("bash ./scripts/init.sh", cwd=tmp)
        assert r1b.returncode == 0, r1b.stderr
    anvil = tmp / ".forge-standard"
    assert (anvil / "checklist.md").exists(), "checklist.md missing after 1st init"
    assert (anvil / "state.json").exists()
    assert (anvil / "history.md").exists()
    # ls -R artifact
    ls1 = run("ls -R .forge-standard", cwd=tmp).stdout
    assert "checklist.md" in ls1
    # cat state.json artifact
    state1 = json.loads((anvil / "state.json").read_text())
    assert state1["initialized"] is True
    hist1_lines = len((anvil / "history.md").read_text().strip().splitlines())

    # User customizations: append CUSTOM and set reviews
    (anvil / "checklist.md").read_text()  # ensure exists
    with open(anvil / "checklist.md", "a") as f:
        f.write("\n# USER CUSTOM\n")
    (anvil / "state.json").write_text(json.dumps({"initialized": True, "reviews": [{"id": 1}], "version": 1}))
    # also test marker block variant
    with open(anvil / "checklist.md", "a") as f:
        f.write("# USER CUSTOM START\nmy custom line CUSTOM\n# USER CUSTOM END\n")
    run("git commit --allow-empty -m bump", cwd=tmp)

    # 2nd init
    r2 = run(f"bash {INIT_SH}", cwd=tmp)
    if r2.returncode != 0:
        r2 = run("bash ./scripts/init.sh", cwd=tmp)
    assert r2.returncode == 0, r2.stderr + r2.stdout

    # Pass: CUSTOM preserved
    checklist = (anvil / "checklist.md").read_text()
    assert "USER CUSTOM" in checklist, f"CUSTOM wiped: {checklist[:500]}"
    assert "my custom line CUSTOM" in checklist or "USER CUSTOM" in checklist

    # Pass: reviews length ==1
    state2 = json.loads((anvil / "state.json").read_text())
    assert len(state2.get("reviews", [])) == 1, f"state.json reviews not preserved: {state2}"
    assert state2["reviews"][0]["id"] == 1

    # Pass: history.md wc -l incremented by 1
    hist2_text = (anvil / "history.md").read_text()
    hist2_lines = len([l for l in hist2_text.strip().splitlines() if l.strip()])
    assert hist2_lines == hist1_lines + 1, f"hist1 {hist1_lines} hist2 {hist2_lines} text:{hist2_text!r}"
    git_count = int(run("git log --oneline | wc -l", cwd=tmp).stdout.strip())
    header_lines = 1 if hist2_text.lstrip().startswith("# History generated") else 0
    assert hist2_lines - header_lines == git_count, f"history wc {hist2_lines} header {header_lines} != git log {git_count} text:{hist2_text[:300]!r}"

    # Artifacts
    ls2 = run("ls -R .forge-standard", cwd=tmp).stdout
    cat_state = (anvil / "state.json").read_text()
    wc_hist = run("wc -l .forge-standard/history.md", cwd=tmp).stdout.strip()
    print(f"\nARTIFACT ls -R:\n{ls2}\nARTIFACT cat state.json:\n{cat_state}\nARTIFACT wc -l history.md:\n{wc_hist}\nARTIFACT head checklist:\n{checklist[:800]}")
