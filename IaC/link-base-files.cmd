@echo off
setlocal

set /p "target=Enter the path to base folder: "
set /p "destination=Enter the path to the env folder: "

for /d %%A in ("%target%\*") do mklink /d "%destination%\%%~nxA" "%%~A"
mklink "%destination%\main.tf" "%target%\main.tf"
mklink "%destination%\variables.tf" "%target%\variables.tf"