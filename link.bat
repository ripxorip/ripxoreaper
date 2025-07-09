@echo off
setlocal

REM === CONFIG ===
set "REPO_ROOT=C:\dev\ripxoreaper"
set "REAPER_CONFIG=%APPDATA%\REAPER"

REM === Symlink Scripts/ripxorip ===
echo.
echo Checking Scripts\ripxorip symlink...
if exist "%REAPER_CONFIG%\Scripts\ripxorip" (
    echo Already exists: %REAPER_CONFIG%\Scripts\ripxorip
) else (
    echo Creating symlink for Scripts\ripxorip...
    mklink /D "%REAPER_CONFIG%\Scripts\ripxorip" "%REPO_ROOT%\Scripts"
)

REM === Symlink reaper-kb.ini ===
echo.
echo Checking reaper-kb.ini symlink...
if exist "%REAPER_CONFIG%\reaper-kb.ini" (
    echo Already exists: %REAPER_CONFIG%\reaper-kb.ini
) else (
    echo Creating symlink for reaper-kb.ini...
    mklink "%REAPER_CONFIG%\reaper-kb.ini" "%REPO_ROOT%\reaper-kb.ini"
)

REM === Symlink other .ini files as needed ===
REM Add more as you grow: reaper-menu.ini, reaper-screensets.ini, etc.

echo.
echo All done. Symlinks checked!

pause
endlocal