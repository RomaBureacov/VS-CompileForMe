@echo off

:: Set up the Visual Studio environment
:: CHANGE TO YOUR VISUAL STUDIO ENVIRONMENT SETUP
:: YOU WILL NEED TO FIND vcvarsall.bat UNDER APPROXIMATELY THE SAME FILE PATH AS IN THE LINE BELOW
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
if errorlevel 1 (
    echo Failed to load environment, exiting program...
    pause
    exit /b 1
) else (
    echo Successfully loaded environment
)

echo.

:: Prompt for the source directory
:askSourceDirAgain
set /p "source_dir=Enter source directory: "

:: Remove quotes if implemented
set "source_dir=%source_dir:"=%"

if not exist "%source_dir%" (
    echo ^|Directory "%source_dir%" not found, please try again.
    goto askSourceDirAgain
)
echo ^|Source directory found: "%source_dir%"
echo.

:askSourceFileAgain
set /p "source_file=Enter cpp file name: "

:: determine if file name with or without .cpp  provided
set source_file_name=%source_file%
echo %source_file%| findstr /i "\.cpp$" >nul
if errorlevel 1 ( 
    REM if the file does not include .cpp extension
    set "source_file=%source_file%.cpp"
) else (
    for %%F in ("%source_file%") do set "source_file_name=%%~nF"
)

:: verify file exists
if not exist "%source_dir%\%source_file%" (
    echo ^|File "%source_dir%\%source_file%" not found in directory, please try again.
    goto askSourceFileAgain
)
echo ^|File found: "%source_dir%\%source_file%"

:: compile the program
:recompileProgram
set "output_dir=%source_dir%\Compiled"
if not exist "%output_dir%" (
    echo ^|Creating: "%output_dir%"
    mkdir "%output_dir%"
)
echo ^|attempting to compile into: "%output_dir%\%source_file_name%.exe"
echo.

echo ==================== COMPILER ====================
cl /EHsc "%source_dir%\%source_file%" /Fo"%output_dir%\\" /Fe"%output_dir%\%source_file_name%.exe"
echo ==================== END COMPILER ====================
echo.

:: should the program fail to compile
if errorlevel 1 (
:askToRecompileAgain
    echo Program has fail to compile or an error occurred
    echo 1. Attempt to compile the program again
    echo 2. Choose another program to compile
    set /p choice="Choice: "
    if "%choice%"=="1" (
        echo.
        goto recompileProgram
    ) else if "%choice%"=="2" (
        echo.
        goto askSourceFileAgain
    ) else (
        echo ^|Invalid response, please try again.
        echo.
        goto askToRecompileAgain
    )
) else (
    echo Program successfully compiled
)

:: ask to run the compiled program
:askToRunAgain
set /p runProgram="Run the compiled program or recompile? (y/n/r): "
if /i "%runProgram%"=="y" (
    echo ^|Attempting to run: "%output_dir%\%source_file_name%.exe"
    start "%source_file_name%" /d "%output_dir%" cmd /k "%source_file_name%.exe"

) else if /i "%runProgram%"=="r" (
    goto recompileProgram
) else if /i not "%runProgram%"=="n" (
    echo ^|Invalid Response, please try again.
    goto askToRunAgain
)
echo.

:: ask the user if they want to recompile, change directory, or exit
:chooseNextStep
echo Choose what to do next
echo 1. Recompile
echo 2. Choose another program to compile
echo 3. Choose another directory
echo 4. Exit
set /p choice="Choice: "

if "%choice%"=="1" (
    goto recompileProgram
) else if "%choice%"=="2" (
    echo.
    goto askSourceFileAgain
) else if "%choice%"=="3" (
    echo.
    goto askSourceDirAgain
) else if "%choice%"=="4" (
    exit /b 0
) else (
    echo ^|Invalid response, please try again.
    echo.
    goto chooseNextStep
)