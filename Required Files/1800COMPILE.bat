@echo off
:: "Hi! What may I help you with?""
setlocal enabledelayedexpansion

:: set parameters
set "module_support=%~1"
set "cpp_standard=%~2"
set "source_dir=%~3"
set "source_file=%~4"
set "source_file_name=%~5"
set "output_dir=%~6"
set "VS-dir=%~7"

:: ===== COMPILATION =====
echo Loading environment...
call "%VS_dir%\Auxiliary\Build\vcvarsall.bat" x64


:: compile the program
:recompileProgram
:: reset colors and terminal
cls
color

set "output_dir=%source_dir%\Compiled"
if not exist "%output_dir%" (
    echo ^|Creating: "%output_dir%"
    mkdir "%output_dir%"
)
echo ^| Attempting to compile into: "%output_dir%\%source_file_name%.exe"
echo.

set /a compile_error=0
echo =====
echo ==================== COMPILER BEGIN ====================
:: if modules are supported
if !module_support!==1 (
    cl /c /reference "std=%~dp0\std.ifc" /std:c++latest /EHsc "!source_dir!\!source_file!" /Fo"!output_dir!\\"
    set /a compile_error=!errorlevel!
    link  "!output_dir!\!source_file_name!.obj" "%~dp0\std.obj" /OUT:"!output_dir!\!source_file_name!.exe"
) else (
    cl /std:!cpp_standard! /EHsc "!source_dir!\!source_file!" /Fo"!output_dir!\\" /Fe"!output_dir!\!source_file_name!.exe"
)
echo ====================  COMPILER END  ====================
echo =====
echo.


:: should the program fail to compile
set /a compile_error+=!errorlevel!
if !compile_error! neq 0 (
    :askToRecompileAgain
    color 0c
    setlocal disabledelayedexpansion
    echo ! Program has failed to compile or an error occurred
    setlocal enabledelayedexpansion
    echo 1. Attempt to compile the program again
    echo 2. Choose another program to compile ^(exits this window back to main window^)
    set /p choice="> Choice: "
    if "%choice%"=="1" (
        echo.
        goto :recompileProgram
    ) else if "%choice%"=="2" (
        exit 1
    ) else (
        echo ^| Invalid response, please try again.
        echo.
        goto :askToRecompileAgain
    )
) else (
    setlocal disabledelayedexpansion
    echo ! Program successfully compiled
    setlocal enabledelayedexpansion
)

:: ask to run the compiled program
:askToRunAgain
set /p runProgram="> Run the compiled program, exit this window, or recompile? (y/e/r): "
if /i "%runProgram%"=="y" (
    echo ^| Attempting to run: "%output_dir%\%source_file_name%.exe"
    start "%source_file_name%" /d "%output_dir%" cmd /k "%source_file_name%.exe & pause & exit 0"
    goto :askToRunAgain
) else if /i "%runProgram%"=="r" (
    goto :recompileProgram
) else if /i not "%runProgram%"=="e" (
    echo ^| Invalid Response, please try again.
    goto :askToRunAgain
)
exit 0