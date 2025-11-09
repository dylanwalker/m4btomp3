# m4btomp3

A Python script that converts m4b audiobook files into individual MP3 files, with one file per chapter. It automatically extracts chapter metadata using ffprobe and converts each chapter using ffmpeg, while also extracting the cover art if available.

## Features

- **Chapter-based conversion**: Extracts each chapter as a separate MP3 file
- **Metadata extraction**: Uses ffprobe to read chapter information from m4b files
- **Cover art extraction**: Automatically extracts cover.jpg if present in the m4b file
- **Customizable filenames**: Chapters are named with the format `ChapterNumber_ChapterName.mp3`
- **Configurable separator**: Replace spaces with a custom separator character (default: underscore)
- **Batch processing ready**: Process multiple files by calling the script multiple times or wrapping it in a batch script

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
```

### Manual Setup (Alternative)

If you prefer not to run the setup scripts, see the [Manual Setup section](#manual-setup-alternative) below.

## Usage

### Basic Usage

```bash
python m4btomp3.py <input_file> <output_folder>
```

### Arguments

- `input_file` (required): Path to the input m4b or m4a file
- `output_folder` (required): Path where MP3 files and cover art will be saved
- `-s, --separator` (optional): Character to replace spaces in filenames (default: `_`)

### Examples

**Convert an m4b file with default settings:**

```bash
python m4btomp3.py "audiobook.m4b" "output_folder"
```

**Convert with a custom separator (e.g., hyphen):**

```bash
python m4btomp3.py "audiobook.m4b" "output_folder" --separator "-"
```

**Convert with no separator (removes spaces):**

```bash
python m4btomp3.py "audiobook.m4b" "output_folder" -s ""
```

## Output

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

## Performance Notes

- The script uses ffmpeg's `-q:a 9` setting for MP3 encoding (high quality, smaller file size)
- Each chapter is converted independently; larger audiobooks may take considerable time
- The process can be optimized by adjusting the audio quality setting in the code if desired

## Manual Setup (Alternative)

If you prefer to set up m4btomp3 manually without running the setup scripts, follow the instructions for your operating system.

### Linux / macOS Manual Setup

1. **Make the script executable:**
   ```bash
   chmod +x /path/to/m4btomp3.py
   ```

2. **Choose one of these methods to add to PATH:**

   **Option A: Copy to ~/.local/bin (recommended for single user)**
   ```bash
   mkdir -p ~/.local/bin
   cp /full/path/to/m4btomp3.py ~/.local/bin/m4btomp3
   chmod +x ~/.local/bin/m4btomp3
   ```

   **Option B: System-wide copy (requires sudo)**
   ```bash
   sudo cp /full/path/to/m4btomp3.py /usr/local/bin/m4btomp3
   sudo chmod +x /usr/local/bin/m4btomp3
   ```

3. **Update your PATH (if using ~/.local/bin):**
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Verify installation:**
   ```bash
   m4btomp3 --help
   ```

### Windows Manual Setup

1. **Using the provided batch wrapper:**

   Copy `m4btomp3.cmd` to a folder in your PATH, or:
   
   - Create a folder: `C:\Program Files\m4btomp3`
   - Copy `m4btomp3.py` to this folder
   - Create a batch file `m4btomp3.cmd` with this content:
     ```batch
     @echo off
     python "C:\Program Files\m4btomp3\m4btomp3.py" %*
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

### Out of memory on large files
- **Solution**: You can convert the file in smaller chunks or increase available system memory

## Development

### Script Structure

- `get_ffprobe_data()`: Extracts metadata and chapter information
- `extract_cover()`: Extracts cover art to JPEG
- `convert_chapter_to_mp3()`: Converts a single chapter segment to MP3
- `sanitize_filename()`: Cleans up chapter names for use as filenames
- `main()`: Orchestrates the conversion process

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
- The script processes m4b and m4a files; ensure your file has the correct extension
- Chapter ordering follows the metadata in the m4b file
