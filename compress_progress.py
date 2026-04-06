#!/usr/bin/env python3
"""Compress progress.txt by summarizing old entries while keeping recent ones intact.

Keeps the header, Codebase Patterns section, and the N most recent detailed entries.
Older entries are reduced to one-line summaries in a "Previous Iterations" section.

Usage: python3 compress_progress.py [progress.txt] [--keep N]
"""

import argparse
import re
import sys
from pathlib import Path


def parse_entries(content: str) -> tuple[str, str, list[dict]]:
    """Parse progress.txt into header, patterns section, and entries."""
    lines = content.split("\n")

    header_lines = []
    patterns_lines = []
    entry_blocks = []
    current_entry_lines = []
    in_patterns = False
    in_previous_summary = False
    header_done = False

    for line in lines:
        # Detect entry start
        if re.match(r"^## \[.*?\] - ", line):
            header_done = True
            if in_patterns:
                in_patterns = False
            if current_entry_lines:
                entry_blocks.append(current_entry_lines)
            current_entry_lines = [line]
            in_previous_summary = False
            continue

        # Detect crash lines as entries
        if re.match(r"^CRASH at iteration", line) or re.match(r"^ABORTED:", line):
            header_done = True
            if current_entry_lines:
                entry_blocks.append(current_entry_lines)
            current_entry_lines = [line]
            continue

        # Detect Codebase Patterns section
        if re.match(r"^## Codebase Patterns", line, re.IGNORECASE):
            in_patterns = True
            header_done = True
            patterns_lines.append(line)
            continue

        # Detect Previous Iterations summary (from prior compressions)
        if re.match(r"^## Previous Iterations", line, re.IGNORECASE):
            in_previous_summary = True
            header_done = True
            continue

        if in_patterns:
            # End patterns section at next ## heading
            if line.startswith("## "):
                in_patterns = False
                if re.match(r"^## \[.*?\] - ", line):
                    current_entry_lines = [line]
                elif re.match(r"^## Previous Iterations", line, re.IGNORECASE):
                    in_previous_summary = True
                continue
            patterns_lines.append(line)
            continue

        if in_previous_summary:
            # Collect old summaries; end at next ## heading that isn't Previous Iterations
            if line.startswith("## "):
                in_previous_summary = False
                if re.match(r"^## \[.*?\] - ", line):
                    current_entry_lines = [line]
                continue
            # Keep old summary lines — they'll be merged later
            if line.strip().startswith("- "):
                # Store as a "summary" entry
                entry_blocks.append([line.strip()])
            continue

        if not header_done:
            header_lines.append(line)
        elif current_entry_lines:
            current_entry_lines.append(line)
        else:
            header_lines.append(line)

    if current_entry_lines:
        entry_blocks.append(current_entry_lines)

    header = "\n".join(header_lines)
    patterns = "\n".join(patterns_lines)
    entries = []
    for block in entry_blocks:
        entries.append(parse_single_entry(block))

    return header, patterns, entries


def parse_single_entry(lines: list[str]) -> dict:
    """Parse a single entry block into structured data."""
    text = "\n".join(lines)
    entry = {"raw": text, "lines": lines}

    # Check if this is already a summary line
    if len(lines) == 1 and lines[0].startswith("- "):
        entry["is_summary"] = True
        entry["summary"] = lines[0]
        return entry

    entry["is_summary"] = False

    # Extract story ID and title from header
    header_match = re.match(r"^## \[.*?\] - ([^:]+):\s*(.*)", lines[0])
    if header_match:
        entry["story_id"] = header_match.group(1).strip()
        entry["story_title"] = header_match.group(2).strip()

    # Extract status
    status_match = re.search(r"\*\*Status\*\*:\s*(.*)", text)
    if status_match:
        entry["status"] = status_match.group(1).strip()

    # Extract cause (for failures)
    cause_match = re.search(r"\*\*Cause\*\*:\s*(.*)", text)
    if cause_match:
        entry["cause"] = cause_match.group(1).strip()

    # Extract implementation (for successes)
    impl_match = re.search(r"\*\*Implementation\*\*:\s*(.*)", text)
    if impl_match:
        entry["implementation"] = impl_match.group(1).strip()

    # Crash entries
    crash_match = re.match(r"^CRASH at iteration (\d+).*", lines[0])
    if crash_match:
        entry["story_id"] = f"CRASH-iter-{crash_match.group(1)}"
        entry["status"] = "Crash"

    return entry


def summarize_entry(entry: dict) -> str:
    """Create a one-line summary of an entry."""
    if entry.get("is_summary"):
        return entry["summary"]

    story_id = entry.get("story_id", "???")
    status = entry.get("status", "???")
    title = entry.get("story_title", "")

    if "Crash" in status:
        return f"- {story_id}: {status}"

    detail = ""
    if "Fail" in status:
        cause = entry.get("cause", "")
        detail = f" — {cause}" if cause else ""
    elif "Pass" in status:
        impl = entry.get("implementation", "")
        detail = f" — {impl}" if impl else ""
    elif "Block" in status.lower():
        detail = " — blocked after max attempts"

    title_part = f" ({title})" if title else ""
    return f"- {story_id}{title_part}: {status}{detail}"


def compress(content: str, keep: int = 5) -> str:
    """Compress progress.txt, keeping last `keep` detailed entries."""
    header, patterns, entries = parse_entries(content)

    if not entries:
        return content

    # Separate already-summarized entries from full entries
    summary_entries = [e for e in entries if e.get("is_summary")]
    full_entries = [e for e in entries if not e.get("is_summary")]

    # If we have fewer full entries than the keep threshold, no compression needed
    if len(full_entries) <= keep:
        return content

    # Split: older entries to compress, recent to keep
    to_compress = full_entries[:-keep]
    to_keep = full_entries[-keep:]

    # Build summary lines from old summaries + newly compressed entries
    summary_lines = [e["summary"] for e in summary_entries]
    for entry in to_compress:
        summary_lines.append(summarize_entry(entry))

    # Rebuild the file
    parts = [header.rstrip()]

    if patterns.strip():
        parts.append("")
        parts.append(patterns.rstrip())

    if summary_lines:
        parts.append("")
        parts.append("## Previous Iterations")
        parts.extend(summary_lines)

    for entry in to_keep:
        parts.append("")
        parts.append(entry["raw"].rstrip())

    result = "\n".join(parts) + "\n"
    return result


def main():
    parser = argparse.ArgumentParser(description="Compress progress.txt")
    parser.add_argument("file", nargs="?", default="progress.txt",
                        help="Path to progress.txt")
    parser.add_argument("--keep", type=int, default=5,
                        help="Number of recent entries to keep in full (default: 5)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print compressed output without modifying the file")
    args = parser.parse_args()

    path = Path(args.file)
    if not path.exists():
        print(f"File not found: {path}", file=sys.stderr)
        sys.exit(1)

    content = path.read_text()
    original_len = len(content)
    compressed = compress(content, keep=args.keep)
    compressed_len = len(compressed)

    if args.dry_run:
        print(compressed)
    else:
        path.write_text(compressed)

    if original_len > compressed_len:
        saved = original_len - compressed_len
        pct = (saved / original_len) * 100
        print(f"Compressed: {original_len} → {compressed_len} bytes ({pct:.0f}% reduction)",
              file=sys.stderr)
    else:
        print("No compression needed.", file=sys.stderr)


if __name__ == "__main__":
    main()
