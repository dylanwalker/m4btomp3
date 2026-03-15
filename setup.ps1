# Setup script to make m4btomp3 and mp3tom4b callable from anywhere in Windows PowerShell
# Run this script in PowerShell to configure both audiobook tools for command-line access

param(
    [switch]$System
)

Write-Host "Audiobook Tools Setup for Windows PowerShell" -ForegroundColor Cyan
Write-Host ""

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

if ($System) {
    Write-Host "Setting up audiobook tools for all users (system-wide)..."
    Write-Host "This requires administrator privileges"
}
else {
    Write-Host "Setting up audiobook tools for current user"
}

# Determine where to place the batch wrapper
if ($System) {
    # System-wide installation - requires admin
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "✗ Error: Administrator privileges required for system-wide installation" -ForegroundColor Red
        Write-Host "  Please run this script as administrator, or use without -System flag" -ForegroundColor Red
        exit 1
    }
    $TargetDir = "C:\Program Files\m4btomp3"
}
else {
    # User-specific installation
    $TargetDir = Join-Path $env:USERPROFILE "AppData\Local\m4btomp3"
}

# Create target directory
Write-Host "Creating directory: $TargetDir"
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# Copy the main scripts
$Tools = @(
    @{
        Script = "m4btomp3.py"
        Command = "m4btomp3.cmd"
        Description = "Convert m4b audiobooks to MP3 chapters"
    },
    @{
        Script = "mp3tom4b.py"
        Command = "mp3tom4b.cmd"
        Description = "Convert a folder of MP3 chapters into an M4B audiobook"
    }
)

foreach ($Tool in $Tools) {
    $ScriptSource = Join-Path $ScriptDir $Tool.Script
    $ScriptDestination = Join-Path $TargetDir $Tool.Script

    Write-Host "Copying $($Tool.Script) to $TargetDir..."
    Copy-Item $ScriptSource -Destination $ScriptDestination -Force

    $BatchContent = @"
@echo off
REM $($Tool.Command) - $($Tool.Description)
REM This batch file calls the Python script

python "%~dp0$($Tool.Script)" %*
"@

    $BatchPath = Join-Path $TargetDir $Tool.Command
    Set-Content -Path $BatchPath -Value $BatchContent -Encoding ASCII

    Write-Host "✓ Batch wrapper created: $BatchPath"
}

Write-Host ""

# Add to PATH
if ($System) {
    Write-Host "Adding to system PATH..."
    $CurrentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($CurrentPath -notlike "*$TargetDir*") {
        $NewPath = "$TargetDir;$CurrentPath"
        [Environment]::SetEnvironmentVariable("PATH", $NewPath, "Machine")
        Write-Host "✓ Added $TargetDir to system PATH"
    }
    else {
        Write-Host "✓ $TargetDir is already in system PATH"
    }
}
else {
    Write-Host "Adding to user PATH..."
    $CurrentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($CurrentPath -notlike "*$TargetDir*") {
        $NewPath = if ($CurrentPath) { "$TargetDir;$CurrentPath" } else { $TargetDir }
        [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
        Write-Host "✓ Added $TargetDir to user PATH"
    }
    else {
        Write-Host "✓ $TargetDir is already in user PATH"
    }
}

Write-Host ""
Write-Host "✓ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now call these commands from any command prompt:"
Write-Host "  m4btomp3 <input_file> <output_folder>"
Write-Host "  m4btomp3 --help"
Write-Host "  mp3tom4b <input_folder> --output <output_file>"
Write-Host "  mp3tom4b --help"
Write-Host ""
Write-Host "Examples:"
Write-Host "  m4btomp3 audiobook.m4b output_folder"
Write-Host "  m4btomp3 book.m4b chapters/ --separator `"-`""
Write-Host "  mp3tom4b chapters\ --output audiobook.m4b"
Write-Host "  mp3tom4b chapters\ --cover cover.png --bitrate 96k"
Write-Host ""

if (-not $System) {
    Write-Host "Note: You may need to restart your PowerShell or Command Prompt for PATH changes to take effect."
}
