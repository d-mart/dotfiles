"""Checks for the Claude Code status line pieces: bin/ccstatusline-fast and the
statusLine patch in deploy.sh.

What matters most is that neither ever lets ccstatusline read a whole session
transcript again (see docs/claude-statusline-last-reply.md), so a regression
fails here rather than showing up as a pinned CPU.

Run from the repo root:  python3 -m unittest discover -s tests
"""

import importlib.machinery
import importlib.util
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_wrapper():
    path = os.path.join(REPO, "bin", "ccstatusline-fast")
    loader = importlib.machinery.SourceFileLoader("ccstatusline_fast", path)
    spec = importlib.util.spec_from_loader("ccstatusline_fast", loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def read(path):
    with open(path, "rb") as fh:
        return fh.read()


def record(kind, pad=0):
    return json.dumps({"type": kind, "pad": "x" * pad}, separators=(",", ":")).encode() + b"\n"


class TailCopyTest(unittest.TestCase):
    def setUp(self):
        self.w = load_wrapper()
        self.w.TAIL_BYTES = 1000
        self.w.MAX_TAIL_BYTES = 8000
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.runtime = os.path.join(self.tmp.name, "run")
        os.mkdir(self.runtime)
        self.old_env = os.environ.get("XDG_RUNTIME_DIR")
        os.environ["XDG_RUNTIME_DIR"] = self.runtime
        self.addCleanup(self.restore_env)
        self.project = os.path.join(self.tmp.name, "project")
        os.mkdir(self.project)
        self.transcript = os.path.join(self.project, "abc-123.jsonl")

    def restore_env(self):
        if self.old_env is None:
            os.environ.pop("XDG_RUNTIME_DIR", None)
        else:
            os.environ["XDG_RUNTIME_DIR"] = self.old_env

    def write(self, data):
        with open(self.transcript, "wb") as fh:
            fh.write(data)

    def test_small_transcript_is_used_as_is(self):
        self.write(record("assistant"))
        self.assertEqual(self.w.tail_copy(self.transcript), self.transcript)

    def test_large_transcript_copy_is_whole_lines_from_the_end(self):
        lines = [record("assistant", 50) for _ in range(100)]
        self.write(b"".join(lines))
        copy = self.w.tail_copy(self.transcript)
        self.assertNotEqual(copy, self.transcript)
        self.assertTrue(copy.startswith(self.runtime))
        self.assertEqual(os.path.basename(copy), "abc-123.jsonl")  # ccstatusline derives the subagents dir from the stem
        data = read(copy)
        self.assertLessEqual(len(data), self.w.TAIL_BYTES)
        self.assertTrue(data.endswith(lines[-1]))
        for line in data.splitlines():
            json.loads(line)  # no partial first line

    def test_line_starting_exactly_at_the_cut_is_kept(self):
        tail = record("assistant", 1000 - len(record("assistant")))
        self.assertEqual(len(tail), 1000)
        self.write(record("user", 500) + tail)
        data = read(self.w.tail_copy(self.transcript))
        self.assertEqual(data, tail)

    def test_window_grows_until_it_holds_an_assistant_record(self):
        self.write(record("assistant") + b"".join(record("user", 400) for _ in range(6)))
        data = read(self.w.tail_copy(self.transcript))
        self.assertIn(b'"type":"assistant"', data)
        self.assertLessEqual(len(data), self.w.MAX_TAIL_BYTES)

    def test_window_never_exceeds_the_cap(self):
        self.write(record("assistant") + record("user", 20000))
        data = read(self.w.tail_copy(self.transcript))
        self.assertLessEqual(len(data), self.w.MAX_TAIL_BYTES)

    def test_unchanged_transcript_is_not_copied_again(self):
        self.write(b"".join(record("assistant", 100) for _ in range(20)))
        copy = self.w.tail_copy(self.transcript)
        inode = os.stat(copy).st_ino
        self.assertEqual(self.w.tail_copy(self.transcript), copy)
        self.assertEqual(os.stat(copy).st_ino, inode)

    def test_changed_transcript_is_copied_again(self):
        self.write(b"".join(record("assistant", 100) for _ in range(20)))
        copy = self.w.tail_copy(self.transcript)
        newest = record("assistant", 7)
        with open(self.transcript, "ab") as fh:
            fh.write(newest)
        st = os.stat(self.transcript)
        os.utime(self.transcript, ns=(st.st_atime_ns, st.st_mtime_ns + 1_000_000))
        self.w.tail_copy(self.transcript)
        self.assertTrue(read(copy).endswith(newest))

    def test_subagent_dirs_are_linked_next_to_the_copy(self):
        subagents = os.path.join(self.project, "abc-123", "subagents")
        os.makedirs(subagents)
        self.write(b"".join(record("assistant", 100) for _ in range(20)))
        copy = self.w.tail_copy(self.transcript)
        link = os.path.join(os.path.dirname(copy), "abc-123", "subagents")
        self.assertEqual(os.path.realpath(link), os.path.realpath(subagents))

    def test_prune_removes_stale_entries_without_following_links(self):
        cache = self.w.cache_dir()
        keep_target = os.path.join(self.tmp.name, "precious")
        os.mkdir(keep_target)
        stale = os.path.join(cache, "stale")
        os.mkdir(stale)
        os.symlink(keep_target, os.path.join(stale, "subagents"))
        old = time.time() - self.w.CACHE_TTL_SECONDS - 60
        os.utime(stale, (old, old))
        fresh = os.path.join(cache, "fresh")
        os.mkdir(fresh)
        self.w.prune(cache)
        self.assertFalse(os.path.exists(stale))
        self.assertTrue(os.path.isdir(fresh))
        self.assertTrue(os.path.isdir(keep_target))


class RewriteTest(unittest.TestCase):
    """rewrite() must never hand ccstatusline the full transcript."""

    def setUp(self):
        self.w = load_wrapper()
        self.w.TAIL_BYTES = 1000
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.old_env = os.environ.get("XDG_RUNTIME_DIR")
        self.addCleanup(self.restore_env)
        os.environ["XDG_RUNTIME_DIR"] = self.tmp.name
        self.transcript = os.path.join(self.tmp.name, "big.jsonl")
        with open(self.transcript, "wb") as fh:
            fh.write(b"".join(record("assistant", 100) for _ in range(50)))

    def restore_env(self):
        if self.old_env is None:
            os.environ.pop("XDG_RUNTIME_DIR", None)
        else:
            os.environ["XDG_RUNTIME_DIR"] = self.old_env

    def rewrite(self, payload):
        out = self.w.rewrite(json.dumps(payload).encode())
        return json.loads(out)

    def test_points_at_the_tail_copy(self):
        out = self.rewrite({"transcript_path": self.transcript, "model": "m"})
        self.assertNotEqual(out["transcript_path"], self.transcript)
        self.assertEqual(out["model"], "m")

    def test_missing_transcript_drops_the_key(self):
        out = self.rewrite({"transcript_path": os.path.join(self.tmp.name, "nope.jsonl")})
        self.assertNotIn("transcript_path", out)

    def test_unusable_cache_dir_drops_the_key(self):
        blocker = os.path.join(self.tmp.name, "not-a-dir")
        open(blocker, "w").close()
        os.environ["XDG_RUNTIME_DIR"] = blocker
        out = self.rewrite({"transcript_path": self.transcript})
        self.assertNotIn("transcript_path", out)

    def test_other_input_passes_through(self):
        for raw in (b"not json", b"[1]", b'{"a": 1}'):
            self.assertEqual(self.w.rewrite(raw), raw)


class DeployPatchTest(unittest.TestCase):
    """The statusLine patch embedded in deploy.sh."""

    @classmethod
    def setUpClass(cls):
        text = read(os.path.join(REPO, "deploy.sh")).decode()
        match = re.search(r'python3 - "\$HOME/\.claude/settings\.json" "\$srcDir" <<\'EOF\'\n(.*?)\nEOF\n', text, re.S)
        assert match, "statusLine patch not found in deploy.sh"
        cls.script = match.group(1)

    def patch(self, settings, home, src_dir=REPO):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "settings.json")
            with open(path, "w") as fh:
                json.dump(settings, fh)
            result = subprocess.run([sys.executable, "-c", self.script, path, src_dir],
                                    env={**os.environ, "HOME": home}, capture_output=True, text=True, check=True)
            return json.loads(read(path))["statusLine"], result.stderr

    def home_with_wrapper(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        os.makedirs(os.path.join(tmp.name, "bin"))
        open(os.path.join(tmp.name, "bin", "ccstatusline-fast"), "w").close()
        return tmp.name

    def test_direct_commands_are_migrated(self):
        home = self.home_with_wrapper()
        cases = {
            "npx -y ccstatusline@latest": "$HOME/bin/ccstatusline-fast",
            "npx --yes ccstatusline@latest": "$HOME/bin/ccstatusline-fast",
            "bunx -y ccstatusline@latest": "$HOME/bin/ccstatusline-fast",
            "ccstatusline": "$HOME/bin/ccstatusline-fast",
            "/x/.asdf/installs/nodejs/26.12.0/bin/ccstatusline": "$HOME/bin/ccstatusline-fast",
            "ccstatusline --config /a/b.json": "$HOME/bin/ccstatusline-fast --config /a/b.json",
            "ccstatusline --config '/a b/c.json'": "$HOME/bin/ccstatusline-fast --config '/a b/c.json'",
        }
        for before, after in cases.items():
            with self.subTest(before):
                status, _ = self.patch({"statusLine": {"type": "command", "command": before}}, home)
                self.assertEqual(status["command"], after)
                self.assertEqual(status["refreshInterval"], 30)

    def test_other_commands_are_left_alone(self):
        home = self.home_with_wrapper()
        for command in ("$HOME/bin/ccstatusline-fast", "my-own-thing", "ccstatusline-foo"):
            with self.subTest(command):
                status, stderr = self.patch({"statusLine": {"type": "command", "command": command}}, home)
                self.assertEqual(status["command"], command)
                self.assertNotIn("WARNING", stderr)

    def test_unmigratable_ccstatusline_command_warns(self):
        status, stderr = self.patch({"statusLine": {"type": "command", "command": "env X=1 ccstatusline"}},
                                    self.home_with_wrapper())
        self.assertEqual(status["command"], "env X=1 ccstatusline")
        self.assertIn("WARNING", stderr)

    def test_missing_statusline_is_added(self):
        status, _ = self.patch({}, self.home_with_wrapper())
        self.assertEqual(status, {"type": "command", "command": "$HOME/bin/ccstatusline-fast",
                                  "padding": 0, "refreshInterval": 30})

    def test_without_home_bin_link_points_into_the_repo_quoted(self):
        with tempfile.TemporaryDirectory() as home:
            status, _ = self.patch({}, home, src_dir="/path with spaces/dotfiles")
        self.assertEqual(status["command"], "'/path with spaces/dotfiles/bin/ccstatusline-fast'")


if __name__ == "__main__":
    unittest.main()
