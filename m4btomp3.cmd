@echo off
REM Windows batch wrapper to call the Python script
REM This allows calling: m4btomp3 <args>

python "%~dp0m4btomp3.py" %*
