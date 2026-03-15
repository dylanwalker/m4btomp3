#!/usr/bin/env python3
"""
Convert a folder of numbered MP3 files into a single M4B audiobook
with chapter breaks and optional cover art from a PNG in the folder.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path


def run_command(cmd, check=True):
    """Run a shell command and return the result."""
    try:
        result = subprocess.run(cmd, check=check, capture_output=True, text=True)
        return result
    except subprocess.CalledProcessError as error:
        print(f"Error running command: {' '.join(cmd)}")
        print(f"stderr: {error.stderr}")
        raise


def get_duration_ms(filepath):
    """Get the duration of an audio file in milliseconds using ffprobe."""
    cmd = [
        "ffprobe",
        "-v", "error",
        "-print_format", "json",
        "-show_format",
        str(filepath),
    ]
    result = run_command(cmd)
    data = json.loads(result.stdout)
    duration_sec = float(data["format"]["duration"])
    return int(duration_sec * 1000)


def get_sorted_mp3s(folder):
    """Return MP3 files from *folder* sorted by leading number.

    Files are sorted by the first sequence of digits found in their
    filename. Files without any digits sort to the end.
    """
    mp3s = [file_path for file_path in folder.iterdir() if file_path.suffix.lower() == ".mp3" and file_path.is_file()]

    def sort_key(path):
        match = re.search(r"(\d+)", path.stem)
        return int(match.group(1)) if match else float("inf")

    mp3s.sort(key=sort_key)
    return mp3s


def find_cover_image(folder):
    """Return the first PNG file found in *folder*, or None."""
    pngs = sorted(file_path for file_path in folder.iterdir() if file_path.suffix.lower() == ".png" and file_path.is_file())
    return pngs[0] if pngs else None


def chapter_title_from_filename(filepath):
    """Derive a human-readable chapter title from an MP3 filename.

    Strips the leading number/separator and the extension, then
    replaces underscores with spaces.
    """
    stem = filepath.stem
    title = re.sub(r"^\d+[\s_\-\.]*", "", stem)
    title = title.replace("_", " ").strip()
    return title if title else stem


def build_ffmetadata(mp3s, durations):
    """Build an FFMETADATA1 string with chapter entries."""
    lines = [";FFMETADATA1\n"]
    offset = 0
    for mp3, duration in zip(mp3s, durations):
        title = chapter_title_from_filename(mp3)
        lines.append("[CHAPTER]")
        lines.append("TIMEBASE=1/1000")
        lines.append(f"START={offset}")
        lines.append(f"END={offset + duration}")
        lines.append(f"title={title}\n")
        offset += duration
    return "\n".join(lines)


def build_concat_list(mp3s):
    """Build an ffmpeg concat demuxer file contents string."""
    lines = []
    for mp3 in mp3s:
        safe = str(mp3.resolve()).replace("'", "'\\''")
        lines.append(f"file '{safe}'")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Convert a folder of numbered MP3 files into an M4B audiobook with chapters"
    )
    parser.add_argument(
        "input_folder",
        help="Path to the folder containing numbered MP3 files",
    )
    parser.add_argument(
        "-o", "--output",
        default=None,
        help="Output M4B file path (default: <folder_name>.m4b in the input folder's parent)",
    )
    parser.add_argument(
        "-c", "--cover",
        default=None,
        help="Path to a cover image (default: first PNG in the input folder)",
    )
    parser.add_argument(
        "-b", "--bitrate",
        default="64k",
        help="Audio bitrate for AAC encoding (default: 64k)",
    )

    args = parser.parse_args()

    input_folder = Path(args.input_folder)
    if not input_folder.is_dir():
        print(f"✗ Input folder not found: {input_folder}")
        sys.exit(1)

    mp3s = get_sorted_mp3s(input_folder)
    if not mp3s:
        print(f"✗ No MP3 files found in {input_folder}")
        sys.exit(1)

    print(f"Found {len(mp3s)} MP3 file(s) in {input_folder}")

    cover = Path(args.cover) if args.cover else find_cover_image(input_folder)
    if cover and not cover.is_file():
        print(f"✗ Cover image not found: {cover}")
        cover = None
    if cover:
        print(f"Cover image: {cover}")
    else:
        print("No cover image found - proceeding without one")

    if args.output:
        output_path = Path(args.output)
    else:
        output_path = input_folder.parent / f"{input_folder.name}.m4b"

    print("Reading MP3 durations...")
    durations = []
    for mp3 in mp3s:
        duration = get_duration_ms(mp3)
        durations.append(duration)
        print(f"  {mp3.name}  ({duration / 1000:.1f}s)")

    tmp_dir = tempfile.mkdtemp()
    concat_file = Path(tmp_dir) / "concat.txt"
    metadata_file = Path(tmp_dir) / "ffmetadata.txt"

    concat_file.write_text(build_concat_list(mp3s), encoding="utf-8")
    metadata_file.write_text(build_ffmetadata(mp3s, durations), encoding="utf-8")

    cmd = [
        "ffmpeg",
        "-f", "concat",
        "-safe", "0",
        "-i", str(concat_file),
        "-i", str(metadata_file),
    ]

    if cover:
        cmd += ["-i", str(cover)]
        cmd += [
            "-map_metadata", "1",
            "-map", "0:a",
            "-map", "2:v",
            "-c:v", "copy",
            "-disposition:v:0", "attached_pic",
        ]
    else:
        cmd += ["-map_metadata", "1", "-map", "0:a"]

    cmd += [
        "-c:a", "aac",
        "-b:a", args.bitrate,
        "-f", "mp4",
        str(output_path),
        "-y",
    ]

    print(f"\nEncoding M4B -> {output_path}")
    result = run_command(cmd, check=False)

    try:
        concat_file.unlink()
        metadata_file.unlink()
        Path(tmp_dir).rmdir()
    except OSError:
        pass

    if result.returncode != 0:
        print(f"✗ ffmpeg failed:\n{result.stderr}")
        sys.exit(1)

    print(f"✓ Created {output_path}")


if __name__ == "__main__":
    main()
