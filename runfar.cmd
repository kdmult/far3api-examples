@echo off

set FARHOME=%~1
if "%FARHOME%"=="" echo Usage: %~nx0 FarHomeDir & exit /B 1

"%FARHOME%\Far.exe" /w /p%~dp0bin
