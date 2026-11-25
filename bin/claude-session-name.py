#!/usr/bin/env python3
# ccstatusline "Custom Command" widget: the session's name, as set by /rename
# (custom-title), falling back to Claude Code's automatic title (ai-title).
#
# Replaces ccstatusline's session-name widget, which only works when
# ccstatusline scans the whole transcript (see ccstatusline-fast). Current
# Claude Code sends session_name in the status JSON; when it doesn't, this
# falls back to the transcript. Claude Code re-appends the title records as
# the session goes on, so the last MB of the transcript holds the current one.
#
# Reads the Claude Code status JSON on stdin; prints one short segment.

import json
import os
import sys

TAIL_BYTES = 1048576


def session_name(path):
    size = os.path.getsize(path)
    with open(path, "rb") as fh:
        if size > TAIL_BYTES:
            fh.seek(size - TAIL_BYTES)
            fh.readline()  # discard the partial line we landed in
        lines = fh.read().splitlines()
    ai_title = None
    for raw in reversed(lines):
        # Cheap prefilter: only title records are worth decoding.
        if b'-title"' not in raw:
            continue
        try:
            entry = json.loads(raw)
        except ValueError:
            continue
        if entry.get("type") == "custom-title" and entry.get("customTitle"):
            return entry["customTitle"]
        if ai_title is None and entry.get("type") == "ai-title" and entry.get("aiTitle"):
            ai_title = entry["aiTitle"]
    return ai_title


def main():
    try:
        data = json.load(sys.stdin)
        name = data.get("session_name")
        if not name:
            path = data.get("cc_transcript_path") or data.get("transcript_path")
            name = session_name(path) if path and os.path.exists(path) else None
    except Exception:
        name = None
    if name:
        print(f"Session: {name}")


if __name__ == "__main__":
    main()
