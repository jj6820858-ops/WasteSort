@echo off
chcp 65001 >nul
set "APPDIR=%~dp0"
if exist "%APPDIR%dist\WasteSort\WasteSort.exe" (
    start "" "%APPDIR%dist\WasteSort\WasteSort.exe"
) else (
    set "PATH=D:\Qt\6.8.3\mingw_64\bin;D:\Qt\Tools\mingw1310_64\bin;%PATH%"
    start "" "%APPDIR%build\WasteSort.exe"
)
