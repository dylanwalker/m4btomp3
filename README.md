# m4btomp3

This repository contains two Python command-line tools for moving between chapterized MP3 folders and M4B audiobook files:

- `m4btomp3.py`: Converts an m4b audiobook into individual MP3 chapter files and extracts cover art when available
- `mp3tom4b.py`: Converts a folder of numbered MP3 chapter files into a single M4B audiobook with chapter markers and optional cover art

## Features

### m4btomp3

- **Chapter-based conversion**: Extracts each chapter as a separate MP3 file
- **Metadata extraction**: Uses ffprobe to read chapter information from m4b files
- **Cover art extraction**: Automatically extracts `cover.jpg` if present in the m4b file
- **Customizable filenames**: Chapters are named with the format `ChapterNumber_ChapterName.mp3`
- **Configurable separator**: Replace spaces with a custom separator character (default: underscore)

### mp3tom4b

- **Folder-to-audiobook conversion**: Combines a folder of numbered MP3 files into one M4B audiobook
- **Automatic chapter building**: Creates chapter markers based on MP3 durations and filenames
- **Optional cover art**: Embeds a cover image if you provide one, or automatically uses the first PNG found in the folder
- **Ordered chapter detection**: Sorts MP3 files by the first number found in each filename
- **Configurable bitrate**: Lets you control AAC encoding bitrate for the generated M4B file

## Requirements

You must have the following installed on your system:

- **Python 3.7+**: Download from [python.org](https://www.python.org/)
- **FFmpeg**: Download from [ffmpeg.org](https://ffmpeg.org/download.html) or install via package manager
  - Windows (via Chocolatey): `choco install ffmpeg`
  - macOS (via Homebrew): `brew install ffmpeg`
  - Linux (Ubuntu/Debian): `sudo apt-get install ffmpeg`

Ensure that `ffmpeg` and `ffprobe` are available in your system PATH.

## Installation

### Prerequisites

- **Python 3.7+**: Download from [python.org](https://www.python.org/)
- **FFmpeg**: Download from [ffmpeg.org](https://ffmpeg.org/download.html) or install via package manager

Verify installation:
```bash
python --version    # or python3 --version
ffmpeg -version
ffprobe -version
```

### Quick Setup

#### Linux / macOS (Bash)

```bash
cd /path/to/m4btomp3
bash setup.sh
source ~/.bashrc
```

Then verify:
```bash
m4btomp3 --help
mp3tom4b --help
```

**Note:** The setup script detects whether it's run with `sudo`:
- **Without `sudo`**: Installs to `~/.local/bin/` (user-only)
- **With `sudo`**: Installs to `/usr/local/bin/` (system-wide, available to all users and `sudo`)

For system-wide installation that works with `sudo`:
```bash
sudo bash setup.sh
```

#### Windows (PowerShell)

```powershell
cd C:\path\to\m4btomp3
.\setup.ps1
```

For system-wide installation (requires admin):
```powershell
.\setup.ps1 -System
```

Then restart PowerShell or Command Prompt and verify:
```
m4btomp3 --help
mp3tom4b --help
```

### Manual Setup (Alternative)

If you prefer not to run the setup scripts, see the [Manual Setup section](#manual-setup-alternative) below.

## Usage

### m4btomp3

Basic usage:

```bash
python m4btomp3.py <input_file> <output_folder>
```

Arguments:

- `input_file` (required): Path to the input m4b or m4a file
- `output_folder` (required): Path where MP3 files and cover art will be saved
- `-s, --separator` (optional): Character to replace spaces in filenames (default: `_`)

Examples:

```bash
python m4btomp3.py "audiobook.m4b" "output_folder"
python m4btomp3.py "audiobook.m4b" "output_folder" --separator "-"
python m4btomp3.py "audiobook.m4b" "output_folder" -s ""
```

Installed command examples:

```bash
m4btomp3 "audiobook.m4b" "output_folder"
m4btomp3 "audiobook.m4b" "output_folder" --separator "-"
```

### mp3tom4b

Basic usage:

```bash
python mp3tom4b.py <input_folder> [options]
```

Arguments:

- `input_folder` (required): Folder containing the numbered MP3 chapter files
- `-o, --output` (optional): Output M4B path; defaults to `<folder_name>.m4b` in the input folder's parent directory
- `-c, --cover` (optional): Path to a cover image; defaults to the first PNG found in the input folder
- `-b, --bitrate` (optional): AAC bitrate for the output file (default: `64k`)

Examples:

```bash
python mp3tom4b.py "chapters"
python mp3tom4b.py "chapters" --output "audiobook.m4b"
python mp3tom4b.py "chapters" --cover "cover.png" --bitrate "96k"
```

Installed command examples:

```bash
mp3tom4b "chapters"
mp3tom4b "chapters" --output "audiobook.m4b"
mp3tom4b "chapters" --cover "cover.png" --bitrate "96k"
```

## Output

### m4btomp3 output

After running the script, the output folder will contain:

- **cover.jpg**: The extracted cover art from the m4b file (if present)
- **ChapterFiles**: One MP3 file per chapter, named with the format:
  - `01_Chapter_Name.mp3`
  - `02_Another_Chapter.mp3`
  - etc.

The filenames include:
- Chapter number (zero-padded to 2 digits)
- Separator character (default underscore)
- Chapter name (with spaces replaced by the separator, and invalid filename characters removed)

### mp3tom4b output

The generated `.m4b` file includes:

- A single AAC-encoded audiobook file assembled from the input MP3 files
- Chapter markers derived from the MP3 filenames and durations
- Embedded cover art if a PNG cover image is found or specified

## Performance Notes

- `m4btomp3.py` uses ffmpeg's `-q:a 9` setting for MP3 encoding (high quality, smaller file size)
- `mp3tom4b.py` re-encodes audio to AAC using the bitrate you specify with `--bitrate`
- Larger audiobooks may take considerable time in either direction because each source file must be processed by ffmpeg/ffprobe

## Manual Setup (Alternative)

If you prefer to set up the tools manually without running the setup scripts, follow the instructions for your operating system.

### Linux / macOS Manual Setup

1. **Make the scripts executable:**
   ```bash
   chmod +x /path/to/m4btomp3.py
   chmod +x /path/to/mp3tom4b.py
   ```

2. **Choose one of these methods to add to PATH:**

   **Option A: Copy to ~/.local/bin (recommended for single user)**
   ```bash
   mkdir -p ~/.local/bin
   cp /full/path/to/m4btomp3.py ~/.local/bin/m4btomp3
   cp /full/path/to/mp3tom4b.py ~/.local/bin/mp3tom4b
   chmod +x ~/.local/bin/m4btomp3
   chmod +x ~/.local/bin/mp3tom4b
   ```

   **Option B: System-wide copy (requires sudo)**
   ```bash
   sudo cp /full/path/to/m4btomp3.py /usr/local/bin/m4btomp3
   sudo cp /full/path/to/mp3tom4b.py /usr/local/bin/mp3tom4b
   sudo chmod +x /usr/local/bin/m4btomp3
   sudo chmod +x /usr/local/bin/mp3tom4b
   ```

3. **Update your PATH (if using ~/.local/bin):**
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Verify installation:**
   ```bash
   m4btomp3 --help
   mp3tom4b --help
   ```

### Windows Manual Setup

1. **Create wrappers for both tools in a folder on your PATH:**
   
   - Create a folder: `C:\Program Files\m4btomp3`
   - Copy `m4btomp3.py` and `mp3tom4b.py` to this folder
   - Create a batch file `m4btomp3.cmd` with this content:
     ```batch
     @echo off
     python "C:\Program Files\m4btomp3\m4btomp3.py" %*
     ```
   - Create a batch file `mp3tom4b.cmd` with this content:
     ```batch
     @echo off
     python "C:\Program Files\m4btomp3\mp3tom4b.py" %*
     ```

2. **Add folder to PATH:**
   - Right-click "This PC" → Properties
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "System variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\Program Files\m4btomp3`
   - Click OK and restart PowerShell/Command Prompt

3. **Verify installation:**
   ```
   m4btomp3 --help
   mp3tom4b --help
   ```

## Troubleshooting

### "ffmpeg not found"
- **Solution**: Ensure FFmpeg is installed and added to your system PATH
- **Windows**: Download from ffmpeg.org and add the bin folder to PATH
- **macOS/Linux**: Use your package manager (brew, apt-get, etc.)

### "No chapters found"
- **Cause**: The m4b file may not have chapter metadata embedded
- **Solution**: Some m4b files don't have chapter information; in this case, you may need to use a different tool or manually create the chapters

### "No cover art found"
- **Cause**: The m4b file doesn't contain embedded cover art
- **Solution**: This is normal; the script will continue processing chapters without extracting a cover

### "No MP3 files found"
- **Cause**: `mp3tom4b.py` expects one or more `.mp3` files in the input folder
- **Solution**: Ensure your chapter files are MP3s and that you pointed the command at the correct directory

### "Cover image not found"
- **Cause**: You passed `--cover` with a file path that does not exist
- **Solution**: Fix the path or omit `--cover` to let `mp3tom4b.py` auto-detect the first PNG in the folder

### Out of memory on large files
- **Solution**: You can convert the file in smaller chunks or increase available system memory

## Development

### Script Structure

- `get_ffprobe_data()`: Extracts metadata and chapter information
- `extract_cover()`: Extracts cover art to JPEG
- `convert_chapter_to_mp3()`: Converts a single chapter segment to MP3
- `sanitize_filename()`: Cleans up chapter names for use as filenames
- `main()`: Orchestrates the conversion process

### mp3tom4b Structure

- `get_sorted_mp3s()`: Finds and orders MP3 files by leading number
- `find_cover_image()`: Detects the first PNG file to use as cover art
- `build_ffmetadata()`: Builds ffmpeg chapter metadata from filenames and durations
- `build_concat_list()`: Creates the concat demuxer file for ffmpeg
- `main()`: Validates inputs, probes durations, and creates the final M4B file

### Modifying Quality Settings

To change the MP3 quality, edit this line in the `convert_chapter_to_mp3()` function:

```python
"-q:a", "9",  # Change 9 to 0 (highest) through 9 (lowest quality)
```

Lower numbers mean higher quality but larger file sizes.

## License

This script is provided as-is for personal use.

## Notes

- Ensure you have permission to convert any audiobooks you process
- `m4btomp3.py` processes m4b and m4a inputs; chapter ordering follows the embedded metadata
- `mp3tom4b.py` expects chapter files to be named in a way that preserves order, typically with leading numbers such as `01 Intro.mp3`, `02 Chapter Two.mp3`, and so on
