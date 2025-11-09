# Setup script to make m4btomp3 callable from anywhere in Windows PowerShell
# Run this script in PowerShell to configure m4btomp3 for command-line access

param(
    [switch]$System
)

Write-Host "m4btomp3 Setup for Windows PowerShell" -ForegroundColor Cyan
Write-Host ""

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

if ($System) {
    Write-Host "Setting up m4btomp3 for all users (system-wide)..."
    Write-Host "This requires administrator privileges"
}
else {
    Write-Host "Setting up m4btomp3 for current user"
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

# Copy the main script
Write-Host "Copying m4btomp3.py to $TargetDir..."
Copy-Item (Join-Path $ScriptDir "m4btomp3.py") -Destination $TargetDir -Force

# Create batch wrapper
$BatchContent = @"
@echo off
REM m4btomp3 - Convert m4b audiobooks to MP3 chapters
REM This batch file calls the Python script

python "%~dp0m4btomp3.py" %*
"@

$BatchPath = Join-Path $TargetDir "m4btomp3.cmd"
Set-Content -Path $BatchPath -Value $BatchContent -Encoding ASCII

Write-Host "✓ Batch wrapper created: $BatchPath"
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
Write-Host "You can now call m4btomp3 from any command prompt:"
Write-Host "  m4btomp3 <input_file> <output_folder>"
Write-Host "  m4btomp3 --help"
Write-Host ""
Write-Host "Examples:"
Write-Host "  m4btomp3 audiobook.m4b output_folder"
Write-Host "  m4btomp3 book.m4b chapters/ --separator `"-`""
Write-Host ""

if (-not $System) {
    Write-Host "Note: You may need to restart your PowerShell or Command Prompt for PATH changes to take effect."
}
