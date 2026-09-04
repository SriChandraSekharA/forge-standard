"""Scenario B — Edge: no VCS (hg/none) + missing docs fallback to Fowler.
Real FS, real git rev-parse branch, no mocks.
"""
import subprocess
import pathlib
import shutil
import os

REPO_ROOT = pathlib.Path("/Users/webileapps/Chandu/github/forge-standard")
INIT_SH = REPO_ROOT / "scripts" / "init.sh"


def run(cmd, cwd=None, env=None):
    return subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True, env=env)


def test_b_novcs_fallback(tmp_path):
    tmp = tmp_path / "novcs"
    tmp.mkdir()
    # Setup: no .git, no AGENTS.md, but docs/agents/issue-tracker.md with tracker
    docs_agents = tmp / "docs" / "agents"
    docs_agents.mkdir(parents=True)
    (docs_agents / "issue-tracker.md").write_text("tracker content for knowledge\n")
    # copy scripts + references so init can run from tmp (references needed for Fowler fallback)
    shutil.copytree(REPO_ROOT / "scripts", tmp / "scripts")
    shutil.copytree(REPO_ROOT / "references", tmp / "references")
    # Ensure no .git
    assert not (tmp / ".git").exists()
    assert not (tmp / "AGENTS.md").exists()

    # Run init.sh — must NOT exit 128, must exit 0
    r = run(f"bash {INIT_SH}", cwd=tmp)
    # fallback to local copy if absolute fails
    if r.returncode != 0:
        r = run("bash ./scripts/init.sh", cwd=tmp)
    print(f"STDOUT: {r.stdout}\nSTDERR: {r.stderr}\nRC:{r.returncode}")
    assert r.returncode == 0, f"init failed on no-vcs: {r.stderr} {r.stdout}"
    assert "init done" in r.stdout

    anvil = tmp / ".forge-standard"
    assert anvil.exists(), "anvil dir not created"
    ls = run("ls -R .forge-standard", cwd=tmp).stdout
    print(f"ls -R: {ls}")
    # history.md contains no-vcs without exit 1
    hist = (anvil / "history.md").read_text() if (anvil / "history.md").exists() else ""
    print(f"history.md: {hist!r}")
    assert "no-vcs" in hist, f"history.md should contain no-vcs, got {hist!r}"

    # knowledge.md contains tracker OR Fowler + Long Method
    know = (anvil / "knowledge.md").read_text() if (anvil / "knowledge.md").exists() else ""
    print(f"knowledge.md head 400: {know[:400]}")
    has_tracker = "tracker" in know.lower()
    has_fowler = "fowler" in know.lower()
    has_long_method = "Long Method" in know
    assert has_tracker or (has_fowler and has_long_method), \
        f"knowledge.md must contain tracker or Fowler/Long Method, got {know[:600]!r}"

    # git rev-parse branch — verify git reports not inside work tree
    rp = run("git rev-parse --is-inside-work-tree", cwd=tmp)
    assert rp.returncode != 0, "should not be inside git work tree"
    # hg check
    hg = run("hg root", cwd=tmp)
    # hg may be missing, but ensure history path was no-vcs, not hg log
    assert "no-vcs" in hist

    # Verify no crash artifacts
    state = (anvil / "state.json").read_text() if (anvil / "state.json").exists() else ""
    print(f"state.json: {state[:500]}")
    wc = run("wc -l .forge-standard/history.md", cwd=tmp).stdout.strip()
    print(f"wc -l history.md: {wc}")

    # Second variant: no docs at all -> must fallback to Fowler
    tmp2 = tmp_path / "novcs2"
    tmp2.mkdir()
    shutil.copytree(REPO_ROOT / "scripts", tmp2 / "scripts")
    shutil.copytree(REPO_ROOT / "references", tmp2 / "references")
    r2 = run(f"bash {INIT_SH}", cwd=tmp2)
    if r2.returncode != 0:
        r2 = run("bash ./scripts/init.sh", cwd=tmp2)
    assert r2.returncode == 0
    know2 = (tmp2 / ".forge-standard" / "knowledge.md").read_text()
    assert "Fowler" in know2 and "Long Method" in know2, f"Fowler fallback failed: {know2[:500]}"
    hist2 = (tmp2 / ".forge-standard" / "history.md").read_text()
    assert "no-vcs" in hist2
    print(f"Fowler fallback OK: {know2[:300]}")
