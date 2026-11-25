#!/usr/bin/env python3
# ccstatusline "Custom Command" widget: recent output speed, in output tokens
# per second of model time, over the last few dozen API requests.
#
# Replaces ccstatusline's output-speed widget, which scans the whole transcript
# and every subagent transcript on each refresh (see ccstatusline-fast). The
# status JSON has no session-wide output total (context_window counts only the
# current turn), so this reads the tail of the transcript and times each
# request the way ccstatusline does: from the user/tool-result record before
# it to its last streamed assistant record, keeping the largest output count.
#
# Reads the Claude Code status JSON on stdin; prints one short segment.

import json
import os
import sys
from datetime import datetime

TAIL_BYTES = 2 * 1048576
MAX_REQUESTS = 50


def parse_ts(value):
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp()
    except (AttributeError, ValueError):
        return None


def output_speed(path):
    size = os.path.getsize(path)
    with open(path, "rb") as fh:
        if size > TAIL_BYTES:
            fh.seek(size - TAIL_BYTES)
            fh.readline()  # discard the partial line we landed in
        lines = fh.read().splitlines()

    requests = {}  # message id -> [start, end, output_tokens]; dicts keep order
    last_user = None
    for raw in lines:
        if b'"type":"user"' not in raw and b'"type":"assistant"' not in raw:
            continue
        try:
            entry = json.loads(raw)
        except ValueError:
            continue
        if entry.get("isSidechain") or entry.get("isApiErrorMessage"):
            continue
        ts = parse_ts(entry.get("timestamp"))
        if ts is None:
            continue
        if entry.get("type") == "user":
            last_user = ts
            continue
        message = entry.get("message") or {}
        usage = message.get("usage")
        msg_id = message.get("id")
        if entry.get("type") != "assistant" or not usage or not msg_id or last_user is None:
            continue
        out = usage.get("output_tokens") or 0
        req = requests.get(msg_id)
        if req is None:
            requests[msg_id] = [last_user, ts, out]
        else:
            req[1] = max(req[1], ts)
            req[2] = max(req[2], out)

    recent = list(requests.values())[-MAX_REQUESTS:]
    tokens = sum(r[2] for r in recent)
    seconds = sum(r[1] - r[0] for r in recent if r[1] > r[0])
    return tokens / seconds if tokens and seconds > 0 else None


def main():
    try:
        data = json.load(sys.stdin)
        path = data.get("cc_transcript_path") or data.get("transcript_path")
        speed = output_speed(path) if path and os.path.exists(path) else None
    except Exception:
        speed = None
    if speed is not None:
        print(f"Out: {speed:.1f} t/s")


if __name__ == "__main__":
    main()
