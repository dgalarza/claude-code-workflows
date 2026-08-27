"""Focused tests for the quality-gate.py template shipped in agent-ready.

They prove the three properties the pattern promises:
  1. unchanged legacy debt passes once it is baselined and reviewed
  2. new or worsened debt fails
  3. stale baseline entries are detected and removed by --prune

Plus the guard rails: an unreviewed baseline fails, baselining requires a
reason, baselining is refused in CI, and --changed-only is merge-base aware.

Run:  python3 -m unittest discover -s plugins/agent-ready/tests -v
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
ENGINE = os.path.join(HERE, "..", "skills", "agent-ready", "assets", "quality-gate.py")


class QualityGateTest(unittest.TestCase):
    def setUp(self):
        self.repo = tempfile.mkdtemp(prefix="qg-")
        self.addCleanup(shutil.rmtree, self.repo, ignore_errors=True)
        self.git("init", "-q", "-b", "main", ".")
        self.git("config", "user.email", "t@t")
        self.git("config", "user.name", "t")
        # Findings are simulated by a file the "tool" cats, one unix-format finding per line.
        self.write("findings.txt", "src/legacy.py:10:1: function 'a' has complexity 14 [complexity]\n"
                                   "src/legacy.py:40:1: function 'b' has complexity 12 [complexity]\n"
                                   "src/dup.py:1:1: 30 duplicated lines with src/other.py [duplication]\n")
        self.write(".quality-gate.json", json.dumps({
            "version": 1, "base_ref": "main", "baseline": ".quality-baseline.json",
            "checks": {
                "complexity": {"command": "grep complexity findings.txt || true", "format": "unix"},
                "duplication": {"command": "grep duplication findings.txt || true", "format": "unix"},
            },
        }))
        self.git("add", "-A")
        self.git("commit", "-qm", "init")

    # helpers
    def git(self, *args):
        return subprocess.run(["git", *args], cwd=self.repo, check=True, text=True, capture_output=True).stdout

    def write(self, rel, content):
        path = os.path.join(self.repo, rel)
        os.makedirs(os.path.dirname(path) or path, exist_ok=True) if os.path.dirname(rel) else None
        with open(path, "w") as fh:
            fh.write(content)

    def gate(self, *args, env=None):
        full_env = {k: v for k, v in os.environ.items() if k not in ("CI", "GITHUB_ACTIONS")}
        full_env.update(env or {})
        return subprocess.run([sys.executable, ENGINE, "--config", os.path.join(self.repo, ".quality-gate.json"), *args],
                              cwd=self.repo, text=True, capture_output=True, env=full_env)

    def read_config(self):
        with open(os.path.join(self.repo, ".quality-gate.json")) as fh:
            return json.load(fh)

    def baseline(self):
        with open(os.path.join(self.repo, ".quality-baseline.json")) as fh:
            return json.load(fh)

    def bless_and_approve(self):
        r = self.gate("baseline", "--reason", "legacy debt inventoried before enabling the gate")
        self.assertEqual(r.returncode, 0, r.stderr + r.stdout)
        r = self.gate("baseline", "--approve", "--reviewed-by", "reviewer")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.git("add", "-A")
        self.git("commit", "-qm", "baseline")

    # 1. legacy debt passes
    def test_no_baseline_reports_all_legacy_debt_as_new(self):
        r = self.gate("check")
        self.assertEqual(r.returncode, 1)
        self.assertIn("NEW debt", r.stdout)
        self.assertIn("3", r.stdout.split("NEW debt (not in baseline): ")[1][:2])

    def test_unchanged_legacy_debt_passes_after_review(self):
        self.bless_and_approve()
        r = self.gate("check")
        self.assertEqual(r.returncode, 0, r.stdout)
        self.assertIn("quality gate passed", r.stdout)
        self.assertEqual(len(self.baseline()["entries"]), 3)

    def test_moving_legacy_debt_to_other_lines_still_passes(self):
        self.bless_and_approve()
        self.write("findings.txt", "src/legacy.py:99:1: function 'a' has complexity 14 [complexity]\n"
                                   "src/legacy.py:140:1: function 'b' has complexity 12 [complexity]\n"
                                   "src/dup.py:7:1: 30 duplicated lines with src/other.py [duplication]\n")
        self.assertEqual(self.gate("check").returncode, 0)

    # 2. new / worsened fails
    def test_new_debt_fails(self):
        self.bless_and_approve()
        with open(os.path.join(self.repo, "findings.txt"), "a") as fh:
            fh.write("src/new.py:3:1: function 'c' has complexity 11 [complexity]\n")
        r = self.gate("check")
        self.assertEqual(r.returncode, 1)
        self.assertIn("src/new.py", r.stdout)
        self.assertIn("1 new and 0 worsened", r.stdout)

    def test_worsened_metric_fails(self):
        self.bless_and_approve()
        self.write("findings.txt", "src/legacy.py:10:1: function 'a' has complexity 22 [complexity]\n"
                                   "src/legacy.py:40:1: function 'b' has complexity 12 [complexity]\n"
                                   "src/dup.py:1:1: 30 duplicated lines with src/other.py [duplication]\n")
        r = self.gate("check")
        self.assertEqual(r.returncode, 1)
        self.assertIn("WORSENED", r.stdout)
        self.assertIn("metric 14 -> 22", r.stdout)

    def test_worsened_count_fails(self):
        self.bless_and_approve()
        with open(os.path.join(self.repo, "findings.txt"), "a") as fh:
            fh.write("src/dup.py:50:1: 30 duplicated lines with src/other.py [duplication]\n")
        r = self.gate("check")
        self.assertEqual(r.returncode, 1)
        self.assertIn("count 1 -> 2", r.stdout)

    def test_github_annotations_emitted_in_actions(self):
        self.bless_and_approve()
        with open(os.path.join(self.repo, "findings.txt"), "a") as fh:
            fh.write("src/new.py:3:1: function 'c' has complexity 11 [complexity]\n")
        r = self.gate("check", env={"GITHUB_ACTIONS": "true"})
        self.assertIn("::error file=src/new.py,line=3,title=New quality debt::", r.stdout)

    # 3. stale entries removed
    def test_fixed_debt_is_stale_until_pruned(self):
        self.bless_and_approve()
        self.write("findings.txt", "src/legacy.py:10:1: function 'a' has complexity 14 [complexity]\n"
                                   "src/dup.py:1:1: 30 duplicated lines with src/other.py [duplication]\n")
        r = self.gate("check")
        self.assertEqual(r.returncode, 1)
        self.assertIn("STALE baseline entries", r.stdout)
        self.assertEqual(self.gate("check", "--allow-stale").returncode, 0)
        r = self.gate("baseline", "--prune")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("pruned 1 stale entry", r.stdout)
        self.assertEqual(len(self.baseline()["entries"]), 2)
        self.assertTrue(self.baseline()["reviewed"], "prune only tightens, so review status is kept")
        self.assertEqual(self.gate("check").returncode, 0)

    def test_improved_metric_is_tightened_by_prune(self):
        self.bless_and_approve()
        self.write("findings.txt", "src/legacy.py:10:1: function 'a' has complexity 11 [complexity]\n"
                                   "src/legacy.py:40:1: function 'b' has complexity 12 [complexity]\n"
                                   "src/dup.py:1:1: 30 duplicated lines with src/other.py [duplication]\n")
        r = self.gate("check")
        self.assertEqual(r.returncode, 0)
        self.assertIn("1 improvement(s) available to prune", r.stdout)
        self.gate("baseline", "--prune")
        metrics = sorted(e["metric"] for e in self.baseline()["entries"].values() if e["check"] == "complexity")
        self.assertEqual(metrics, [11, 12])
        # regressing back to the old value now fails: the ratchet only tightens
        self.write("findings.txt", "src/legacy.py:10:1: function 'a' has complexity 14 [complexity]\n"
                                   "src/legacy.py:40:1: function 'b' has complexity 12 [complexity]\n"
                                   "src/dup.py:1:1: 30 duplicated lines with src/other.py [duplication]\n")
        self.assertEqual(self.gate("check").returncode, 1)

    # guard rails around blessing debt
    def test_baseline_requires_reason(self):
        r = self.gate("baseline")
        self.assertEqual(r.returncode, 2)
        self.assertIn("--reason is required", r.stderr)

    def test_baseline_refused_in_ci(self):
        r = self.gate("baseline", "--reason", "x", env={"CI": "true"})
        self.assertEqual(r.returncode, 2)
        self.assertIn("refusing to create or extend a baseline in CI", r.stderr)

    def test_unreviewed_baseline_fails_check(self):
        r = self.gate("baseline", "--reason", "inventory")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("NOT yet approved", r.stdout)
        self.assertIn("by rule:", r.stdout)
        r = self.gate("check")
        self.assertEqual(r.returncode, 1)
        self.assertIn("not been human-reviewed", r.stdout)

    def test_extend_resets_review_and_records_reason(self):
        self.bless_and_approve()
        with open(os.path.join(self.repo, "findings.txt"), "a") as fh:
            fh.write("src/new.py:3:1: function 'c' has complexity 11 [complexity]\n")
        r = self.gate("baseline", "--extend", "--reason", "vendored generated module")
        self.assertEqual(r.returncode, 0, r.stderr)
        b = self.baseline()
        self.assertFalse(b["reviewed"])
        new_entry = [e for e in b["entries"].values() if e["file"] == "src/new.py"][0]
        self.assertEqual(new_entry["reason"], "vendored generated module")
        self.assertEqual(self.gate("check").returncode, 1)

    def test_create_refuses_when_baseline_exists(self):
        self.bless_and_approve()
        r = self.gate("baseline", "--reason", "again")
        self.assertEqual(r.returncode, 2)
        self.assertIn("use --extend", r.stderr)

    def test_dry_run_writes_nothing(self):
        r = self.gate("baseline", "--reason", "x", "--dry-run")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertFalse(os.path.exists(os.path.join(self.repo, ".quality-baseline.json")))

    # merge-base awareness
    def test_changed_only_scopes_to_files_changed_since_merge_base(self):
        self.bless_and_approve()
        self.git("checkout", "-qb", "feature")
        self.write("src/new.py", "x = 1\n")
        with open(os.path.join(self.repo, "findings.txt"), "a") as fh:
            fh.write("src/new.py:1:1: function 'c' has complexity 11 [complexity]\n")
            fh.write("src/untouched.py:1:1: function 'd' has complexity 11 [complexity]\n")
        self.git("add", "src/new.py")
        self.git("commit", "-qm", "feature work")
        r = self.gate("check", "--changed-only")
        self.assertEqual(r.returncode, 1)
        self.assertIn("src/new.py", r.stdout)
        self.assertNotIn("src/untouched.py", r.stdout)
        r = self.gate("check")
        self.assertIn("src/untouched.py", r.stdout)
        self.assertIn("(outside this change)", r.stdout)

    def test_changed_only_includes_modified_uncommitted_tracked_files(self):
        self.bless_and_approve()
        self.write("src/tracked.py", "x = 1\n")
        self.git("add", "src/tracked.py")
        self.git("commit", "-qm", "add tracked file")
        self.git("checkout", "-qb", "feature")
        # modify the tracked file without committing, and make the analyzer flag it
        self.write("src/tracked.py", "x = 2\n")
        with open(os.path.join(self.repo, "findings.txt"), "a") as fh:
            fh.write("src/tracked.py:1:1: function 'e' has complexity 11 [complexity]\n")
        r = self.gate("check", "--changed-only")
        self.assertEqual(r.returncode, 1)
        self.assertIn("src/tracked.py", r.stdout)
        self.assertIn("<- in this change", r.stdout)

    def test_tool_failure_is_an_error_not_a_pass(self):
        self.bless_and_approve()
        cfg = self.read_config()
        cfg["checks"]["complexity"]["command"] = "exit 3"
        self.write(".quality-gate.json", json.dumps(cfg))
        r = self.gate("check")
        self.assertEqual(r.returncode, 1)
        self.assertIn("check error", r.stdout)

    def test_jsonl_format(self):
        cfg = self.read_config()
        cfg["checks"] = {"dead": {"command": "cat dead.jsonl", "format": "jsonl", "metric": False}}
        self.write(".quality-gate.json", json.dumps(cfg))
        self.write("dead.jsonl", '{"file": "src/a.py", "line": 4, "rule": "unused-export", "message": "unused export foo"}\n')
        self.bless_and_approve()
        self.assertEqual(self.gate("check").returncode, 0)
        self.write("dead.jsonl", '{"file": "src/a.py", "line": 4, "rule": "unused-export", "message": "unused export foo"}\n'
                                 '{"file": "src/b.py", "line": 9, "rule": "unused-export", "message": "unused export bar"}\n')
        self.assertEqual(self.gate("check").returncode, 1)


if __name__ == "__main__":
    unittest.main()
