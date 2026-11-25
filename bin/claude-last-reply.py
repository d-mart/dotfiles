#!/usr/bin/env python3
# ccstatusline "Custom Command" widget: shows when Claude last replied in this
# session, and how long it has been idle since.
#
# Answers "I switched away from this session -- when did it come back, and how
# long has it been sitting here?" Claude Code's own showMessageTimestamps
# setting is gated behind a server-side flag (tengu_silk_hinge), so the status
# line is the only place this can live today.
#
# Reads the Claude Code status JSON on stdin; prints one short segment.

import json
import os
import sys
from datetime import datetime, timezone

TAIL_BYTES = 262144  # enough to cover a turn with heavy tool output


def last_assistant_time(path):
    size = os.path.getsize(path)
    with open(path, "rb") as fh:
        if size > TAIL_BYTES:
            fh.seek(size - TAIL_BYTES)
            fh.readline()  # discard the partial line we landed in
        lines = fh.read().splitlines()
    for raw in reversed(lines):
        try:
            entry = json.loads(raw)
        except ValueError:
            continue
        if entry.get("type") == "assistant" and entry.get("timestamp"):
            return datetime.fromisoformat(entry["timestamp"].replace("Z", "+00:00"))
    return None


def humanize(seconds):
    if seconds < 60:
        return "now"
    minutes = seconds // 60
    if minutes < 60:
        return f"{minutes}m"
    hours, minutes = divmod(minutes, 60)
    if hours < 24:
        return f"{hours}h{minutes:02d}m"
    days, hours = divmod(hours, 24)
    return f"{days}d{hours}h"


def main():
    try:
        path = json.load(sys.stdin).get("transcript_path")
        when = last_assistant_time(path) if path and os.path.exists(path) else None
    except Exception:
        when = None

    if when is None:
        return

    local = when.astimezone()
    age = int((datetime.now(timezone.utc) - when).total_seconds())
    print(f"↩ {local.strftime('%-I:%M%p').lower()} {humanize(max(age, 0))}")


if __name__ == "__main__":
    main()
