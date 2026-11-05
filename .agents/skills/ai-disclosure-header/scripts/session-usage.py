#!/usr/bin/env python3
"""Print the `usage:` disclosure line for one or more Claude Code sessions.

Sums API usage from the session transcript(s) under ~/.claude/projects, including
each session's subagent transcripts, then prices it from pricing.json (list API
prices; an estimate, not what an Enterprise plan bills).

    python3 -I session-usage.py --session-id <uuid> [--session-id <uuid> ...]
    python3 -I session-usage.py --latest            # newest session for the cwd

Exit codes: 0 ok, 3 no transcript found (fallback line printed: tokens unknown).
The breakdown goes to stderr so stdout is only the line.
"""
import argparse
import collections
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECTS = os.path.expanduser("~/.claude/projects")
FIELDS = ("input_tokens", "output_tokens", "cache_creation_input_tokens", "cache_read_input_tokens")


def find_session_dir_and_file(session_id):
    hits = glob.glob(os.path.join(PROJECTS, "*", session_id + ".jsonl"))
    return hits[0] if hits else None


def latest_session_for_cwd():
    slug = re.sub(r"[^A-Za-z0-9]", "-", os.getcwd())
    files = glob.glob(os.path.join(PROJECTS, slug, "*.jsonl"))
    return max(files, key=os.path.getmtime) if files else None


def transcript_files(main_file):
    """The session's own transcript plus every transcript under <session-id>/ (subagents)."""
    sub_dir = main_file[: -len(".jsonl")]
    subs = sorted(glob.glob(os.path.join(sub_dir, "**", "*.jsonl"), recursive=True))
    return [main_file], subs


def read_messages(path, since=None, until=None):
    """Yield (id, model, usage) for assistant API calls. A call is written once per content
    block, so callers dedupe by id. since/until are ISO-8601 UTC strings (compared as text)."""
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            try:
                rec = json.loads(line)
            except ValueError:
                continue
            ts = rec.get("timestamp") or ""
            if (since and ts < since) or (until and ts and ts > until):
                continue
            msg = rec.get("message") or {}
            usage = msg.get("usage")
            if not usage or msg.get("role") != "assistant":
                continue
            model = msg.get("model")
            if not model or model.startswith("<"):  # '<synthetic>' placeholders
                continue
            yield msg.get("id") or rec.get("uuid"), model, usage


def split_cache_writes(u):
    cc = u.get("cache_creation")
    total = u.get("cache_creation_input_tokens") or 0
    if isinstance(cc, dict) and ("ephemeral_5m_input_tokens" in cc or "ephemeral_1h_input_tokens" in cc):
        w1h = cc.get("ephemeral_1h_input_tokens") or 0
        w5m = cc.get("ephemeral_5m_input_tokens") or 0
        return w5m + max(total - w5m - w1h, 0), w1h  # any unattributed remainder counts as 5m
    return total, 0


def match_model(model_id, prices):
    """Exact key, or key + an 8-digit date suffix (claude-haiku-4-5-20251001)."""
    best = None
    for key in prices:
        if model_id == key or re.fullmatch(re.escape(key) + r"-\d{8}", model_id):
            best = key if best is None or len(key) > len(best) else best
    return best


def fmt_tokens(n):
    if n >= 1_000_000:
        return "{:.1f}M".format(n / 1_000_000)
    if n >= 1_000:
        return "{}k".format(round(n / 1_000))
    return str(n)


def fmt_cost(c):
    return "${:.2f}".format(c) if c < 100 else "${:,.0f}".format(c)


def display_name(model_id, prices):
    key = match_model(model_id, prices)
    if key:
        return prices[key]["display"]
    name = re.sub(r"^claude-", "", model_id)
    name = re.sub(r"-\d{8}$", "", name)
    return name.replace("-", " ").title()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--session-id", action="append", default=[], help="repeat to include more sessions")
    ap.add_argument("--latest", action="store_true", help="use the newest session transcript for the cwd")
    ap.add_argument("--since", help="only count calls at/after this ISO UTC time, e.g. 2026-11-05T14:00:00Z")
    ap.add_argument("--until", help="only count calls at/before this ISO UTC time (to measure part of a session)")
    ap.add_argument("--harness", default="Claude Code")
    ap.add_argument("--effort", help="only pass when it differs from the default (high)")
    ap.add_argument("--model-fallback", default="unknown", help="model shown when no transcript is found")
    ap.add_argument("--pricing", default=os.path.join(HERE, "pricing.json"))
    args = ap.parse_args()

    with open(args.pricing) as fh:
        pricing = json.load(fh)
    prices = pricing["models"]

    mains = []
    for sid in args.session_id:
        f = find_session_dir_and_file(sid)
        if f:
            mains.append(f)
        else:
            print("warning: no transcript for session " + sid, file=sys.stderr)
    if args.latest:
        f = latest_session_for_cwd()
        if f and f not in mains:
            mains.append(f)
    if not mains:
        print("usage: {} · {} · tokens: unknown · cost: unknown".format(args.model_fallback, args.harness))
        print("error: no session transcript found", file=sys.stderr)
        return 3

    # dedupe API calls across every transcript (forks/handoffs can repeat history), keeping per-field max
    calls = {}
    n_sessions, subagent_files = len(mains), 0
    for main_file in mains:
        top, subs = transcript_files(main_file)
        for path in top + subs:
            seen_any = False
            for mid, model, usage in read_messages(path, args.since, args.until):
                seen_any = True
                cur = calls.setdefault(mid, {"model": model, "u": {k: 0 for k in FIELDS}, "w5m": 0, "w1h": 0, "speed": None})
                for k in FIELDS:
                    cur["u"][k] = max(cur["u"][k], usage.get(k) or 0)
                w5m, w1h = split_cache_writes(usage)
                cur["w5m"], cur["w1h"] = max(cur["w5m"], w5m), max(cur["w1h"], w1h)
                cur["speed"] = usage.get("speed") or cur["speed"]
            if seen_any and path in subs:
                subagent_files += 1

    per_model = collections.OrderedDict()
    peak_ctx = {}  # per model: largest single-call context window (input + cached), for the stderr breakdown
    unmodeled = set()
    unpriced = collections.Counter()
    for c in calls.values():
        u = c["u"]
        t_in, t_out, t_cr = u["input_tokens"], u["output_tokens"], u["cache_read_input_tokens"]
        t_w5m, t_w1h = c["w5m"], c["w1h"]
        agg = per_model.setdefault(c["model"], collections.Counter())
        agg["calls"] += 1
        peak_ctx[c["model"]] = max(peak_ctx.get(c["model"], 0), t_in + t_w5m + t_w1h + t_cr)
        agg["input"] += t_in
        agg["cache_write"] += t_w5m + t_w1h
        agg["cache_read"] += t_cr
        agg["output"] += t_out
        key = match_model(c["model"], prices)
        if not key:
            unpriced[c["model"]] += t_in + t_w5m + t_w1h + t_cr + t_out
            continue
        rate = prices[key]
        if "long_prompt" in rate and (t_in + t_w5m + t_w1h + t_cr) > rate["long_prompt"]["over_tokens"]:
            rate = rate["long_prompt"]  # priced per request by prompt length
        mult = 1.0
        if c["speed"] == "fast":
            if "fast_multiplier" in prices[key]:
                mult = prices[key]["fast_multiplier"]
            else:
                unmodeled.add("fast mode on " + c["model"])
        cost = (t_in * rate["input"] + t_w5m * rate["cache_write_5m"] + t_w1h * rate["cache_write_1h"]
                + t_cr * rate["cache_read"] + t_out * rate["output"]) / 1_000_000 * mult
        agg["cost"] += cost

    total = collections.Counter()
    for agg in per_model.values():
        total.update({k: v for k, v in agg.items() if k != "calls"})
    all_tokens = total["input"] + total["cache_write"] + total["cache_read"] + total["output"]
    cost = total["cost"]
    ordered = sorted(per_model, key=lambda m: -(per_model[m]["cost"] or 0))

    # --- the line ---
    names = " + ".join(display_name(m, prices) for m in ordered) or args.model_fallback
    if args.effort:
        names += " ({} effort)".format(args.effort)
    scope = ""
    parts = []
    if n_sessions > 1:
        parts.append("{} sessions".format(n_sessions))
    if subagent_files:
        parts.append("{} subagent{}".format(subagent_files, "" if subagent_files == 1 else "s"))
    if parts:
        scope = " across " + " + ".join(parts)
    cost_txt = ("≥" if unpriced else "~") + fmt_cost(cost) + " est."
    # the three parts add up to the total: cache reads (cheap re-reads of context), new input
    # (fresh input + cache writes, paid at full price or more) and output
    new_input = total["input"] + total["cache_write"]
    print("usage: {} · {} · ~{} tokens ({} cache reads, {} new input, {} output){} · {}".format(
        names, args.harness, fmt_tokens(all_tokens), fmt_tokens(total["cache_read"]),
        fmt_tokens(new_input), fmt_tokens(total["output"]), scope, cost_txt))

    # --- breakdown (stderr) ---
    err = sys.stderr
    print("--- breakdown (pricing as of {}, {}) ---".format(pricing["as_of"], pricing["source"]), file=err)
    print("sessions: {}  subagent transcripts: {}  unique API calls: {}".format(n_sessions, subagent_files, len(calls)), file=err)
    for m in ordered + [m for m in per_model if m not in ordered]:
        a = per_model[m]
        print("{:<28} calls {:>5}  fresh-in {:>9,}  cache-write {:>10,}  cache-read {:>12,}  out {:>9,}  "
              "peak-context {:>9,}  cost {}".format(
                  m, a["calls"], a["input"], a["cache_write"], a["cache_read"], a["output"],
                  peak_ctx.get(m, 0), fmt_cost(a["cost"]) if m not in unpriced else "UNPRICED"), file=err)
    if unpriced:
        print("warning: no price for {} -> cost is a lower bound".format(", ".join(unpriced)), file=err)
    if unmodeled:
        print("warning: price modifiers not modeled: {}".format(", ".join(sorted(unmodeled))), file=err)
    return 0


if __name__ == "__main__":
    sys.exit(main())
