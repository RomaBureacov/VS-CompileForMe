@echo off
@REM "Hi! What may I help you with?""
setlocal enabledelayedexpansion

cd /d "%~dp0"

@REM set parameters
set "module_support=%~1"
set "cpp_standard=%~2"
set "warning_level=%~3"
set "source_dir=%~4"
set "source_file=%~5"
set "source_file_name=%~6"
set "output_dir=%~7"
set "VS-dir=%~8"

@REM ===== COMPILATION =====
echo Loading environment...
call "%VS_dir%\Auxiliary\Build\vcvarsall.bat" x64

@REM compile the program
:recompileProgram
@REM reset colors and terminal
cls
color
set "output_dir=%source_dir%\Compiled"
if not exist "%output_dir%" (
    echo ^| Creating: "%output_dir%"
    mkdir "%output_dir%"
)
echo ^| Attempting to compile into: "%output_dir%\!source_file_name!.exe"
echo.

echo =====
echo ==================== COMPILER BEGIN ====================
@REM if modules are supported
if !module_support!==1 (
    cl /c /reference "std=%~dp0\std.ifc" /std:c++latest !warning_level! /EHsc "!source_dir!\!source_file!" /Fo"!output_dir!\\"
    if !errorlevel! neq 0 goto :askToRecompileAgain
    link  "!output_dir!\!source_file_name!.obj" "%~dp0\std.obj" /OUT:"!output_dir!\!source_file_name!.exe"
) else (
    cl /std:!cpp_standard! !warning_level! /EHsc "!source_dir!\!source_file!" /Fo"!output_dir!\\" /Fe"!output_dir!\!source_file_name!.exe"
)
echo ====================  COMPILER END  ====================
echo =====
echo.


@REM should the program fail to compile
if !errorlevel! neq 0 (
    :askToRecompileAgain
    color 0c
    setlocal disabledelayedexpansion
    echo ! Program has failed to compile or an error occurred
    setlocal enabledelayedexpansion
    echo 1. Attempt to compile the program again
    echo 2. Choose another program to compile ^(exits this window back to main window^)
    set /p choice="> Choice: "
    if "%choice%"=="1" (
        goto :recompileProgram
    ) else if "%choice%"=="2" (
        exit 1
    ) else (
        echo ^| Invalid response, please try again.
        goto :askToRecompileAgain
    )
) else (
    setlocal disabledelayedexpansion
    echo ! Program successfully compiled
    setlocal enabledelayedexpansion
)


@REM ask to run the compiled program
:askToRunAgain
echo Choose what to do next
echo 1. Run the compiled Program
echo 2. Compile another program under the same directory
echo 3. Recompile the program
echo 4. Exit this window
set /p choice="> choice: "
if /i "%choice%"=="1" (
    echo ^| Attempting to run: "%output_dir%\!source_file_name!.exe"
    start "!source_file_name!" /d "%output_dir%" cmd /k "!source_file_name!.exe & pause & exit 0"
    echo.
    goto :askToRunAgain
) else if /i "%choice%"=="2" (
    @REM Prompt for the source directory
    :askSourceFileAgain
    echo.
    set /p "source_file=> Enter cpp file name: "

    @REM Remove quotes from source file if implemented
    set "source_file=!source_file:"=!"

    @REM assuming the source file is the same as the source file name
    set source_file_name=!source_file!

    @REM if the file name does not contain .cpp extension, append it
    @REM otherwise set the source file name omitting the extension
    echo !source_file!| findstr /i "\.cpp$" >nul
    if errorlevel 1 ( 
        set "source_file=!source_file!.cpp"
    ) else (
        for %%F in ("!source_file!") do set "source_file_name=%%~nF"
    )

    @REM verify source file exists in source directory
    if not exist "%source_dir%\!source_file!" (
        echo ^| File "%source_dir%\!source_file!" not found in directory, please try again.
        goto :askSourceFileAgain
    )
    echo ^| File found: "%source_dir%\!source_file!"
    echo source file : !source_file!
    pause
    pause
    goto :recompileProgram
) else if /i "%choice%"=="3" (
    goto :recompileProgram
) else if /i "%choice%"=="4" (
    @REM blank, completes the branch
) else (
    echo ^| Invalid Response, please try again.
    goto :askToRunAgain
)
echo.

exit 0