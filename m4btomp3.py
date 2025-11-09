#!/usr/bin/env python3
"""
Convert m4b audiobook files to individual mp3 files per chapter.
Extracts chapter metadata using ffprobe and converts using ffmpeg.
Also extracts cover art if present.
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path


def run_command(cmd, check=True):
    """Run a shell command and return the result."""
    try:
        result = subprocess.run(cmd, check=check, capture_output=True, text=True)
        return result
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {' '.join(cmd)}")
        print(f"stderr: {e.stderr}")
        raise


def get_ffprobe_data(input_file):
    """Extract metadata from m4b file using ffprobe."""
    cmd = [
        "ffprobe",
        "-v", "error",
        "-print_format", "json",
        "-show_format",
        "-show_chapters",
        input_file
    ]
    
    result = run_command(cmd)
    return json.loads(result.stdout)


def extract_cover(input_file, output_file):
    """Extract cover art from m4b file."""
    cmd = [
        "ffmpeg",
        "-i", input_file,
        "-an",
        "-vcodec", "copy",
        output_file,
        "-y"
    ]
    
    try:
        result = run_command(cmd, check=False)
        if result.returncode == 0:
            print(f"✓ Cover extracted to {output_file}")
            return True
        else:
            print("✗ No cover art found or extraction failed")
            return False
    except Exception as e:
        print(f"✗ Failed to extract cover: {e}")
        return False


def sanitize_filename(name, separator="_"):
    """Sanitize a string to be used as a filename."""
    # Replace spaces and common problematic characters
    name = name.replace(" ", separator)
    # Remove/replace other problematic characters
    invalid_chars = r'<>:"/\|?*'
    for char in invalid_chars:
        name = name.replace(char, "")
    return name


def convert_chapter_to_mp3(input_file, output_file, start_time, end_time):
    """Convert a chapter segment to mp3 using ffmpeg."""
    cmd = [
        "ffmpeg",
        "-i", input_file,
        "-ss", start_time,
        "-to", end_time,
        "-q:a", "9",
        "-acodec", "libmp3lame",
        "-ac", "2",
        output_file,
        "-y"
    ]
    
    try:
        result = run_command(cmd, check=False)
        if result.returncode == 0:
            return True
        else:
            print(f"✗ Failed to convert: {output_file}")
            return False
    except Exception as e:
        print(f"✗ Error converting chapter: {e}")
        return False


def get_time_string(seconds):
    """Convert seconds to HH:MM:SS format."""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    return f"{hours:02d}:{minutes:02d}:{secs:02d}"


def main():
    parser = argparse.ArgumentParser(
        description="Convert m4b audiobook files to individual mp3 files per chapter"
    )
    parser.add_argument(
        "input_file",
        help="Path to the input m4b file"
    )
    parser.add_argument(
        "output_folder",
        help="Path to the output folder for mp3 files"
    )
    parser.add_argument(
        "-s", "--separator",
        default="_",
        help="Separator character to replace spaces in filenames (default: _)"
    )
    
    args = parser.parse_args()
    
    # Validate input file
    input_file = Path(args.input_file)
    if not input_file.exists():
        print(f"✗ Input file not found: {input_file}")
        sys.exit(1)
    
    if input_file.suffix.lower() not in [".m4b", ".m4a"]:
        print(f"✗ Input file must be m4b or m4a, got: {input_file.suffix}")
        sys.exit(1)
    
    # Create output folder
    output_folder = Path(args.output_folder)
    output_folder.mkdir(parents=True, exist_ok=True)
    
    print(f"Reading metadata from: {input_file}")
    
    try:
        metadata = get_ffprobe_data(str(input_file))
    except Exception as e:
        print(f"✗ Failed to read metadata: {e}")
        sys.exit(1)
    
    # Extract cover art
    cover_path = output_folder / "cover.jpg"
    extract_cover(str(input_file), str(cover_path))
    
    # Get chapters
    chapters = metadata.get("chapters", [])
    
    if not chapters:
        print("✗ No chapters found in the m4b file")
        sys.exit(1)
    
    print(f"Found {len(chapters)} chapters")
    
    # Process each chapter
    for i, chapter in enumerate(chapters, 1):
        chapter_num = chapter.get("id", i)
        
        # Get chapter title
        tags = chapter.get("tags", {})
        chapter_title = tags.get("title", f"Chapter_{i}")
        
        # Sanitize the title for use in filename
        safe_title = sanitize_filename(chapter_title, args.separator)
        
        # Create output filename
        output_filename = f"{chapter_num:02d}{args.separator}{safe_title}.mp3"
        output_path = output_folder / output_filename
        
        # Get start and end times
        start_time = float(chapter.get("start_time", 0))
        end_time = float(chapter.get("end_time", 0))
        
        start_str = get_time_string(start_time)
        end_str = get_time_string(end_time)
        
        print(f"\n[{i}/{len(chapters)}] Converting: {output_filename}")
        print(f"  Time: {start_str} -> {end_str}")
        
        if convert_chapter_to_mp3(str(input_file), str(output_path), start_str, end_str):
            print(f"✓ Saved: {output_filename}")
        else:
            print(f"✗ Failed to convert chapter {i}")
    
    print(f"\n✓ Conversion complete! Files saved to: {output_folder}")


if __name__ == "__main__":
    main()
