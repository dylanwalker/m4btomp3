# Example batch processing script for Windows PowerShell
# This script can convert multiple m4b files in a directory

param(
    [Parameter(Mandatory=$true)]
    [string]$InputFolder,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputBaseFolder,
    
    [string]$Separator = "_"
)

# Get all m4b files in the input folder
$m4bFiles = Get-ChildItem -Path $InputFolder -Filter "*.m4b" -ErrorAction SilentlyContinue

if ($m4bFiles.Count -eq 0) {
    Write-Host "No m4b files found in $InputFolder"
    exit 1
}

Write-Host "Found $($m4bFiles.Count) m4b file(s) to process"

foreach ($file in $m4bFiles) {
    $baseName = $file.BaseName
    $outputFolder = Join-Path $OutputBaseFolder $baseName
    
    Write-Host ""
    Write-Host "Processing: $($file.Name)"
    Write-Host "Output folder: $outputFolder"
    
    # Call the main script
    python m4btomp3.py $file.FullName $outputFolder -s $Separator
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Successfully processed: $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to process: $($file.Name)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✓ Batch processing complete!" -ForegroundColor Green
