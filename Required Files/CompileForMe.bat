@echo off
setlocal enabledelayedexpansion
title VS-CompileForMe
echo ~  ~ ~ ~~~~~-----==========-----~~~~~ ~ ~  ~

:: change to current working directory
cd /d "%~dp0"

:: should the required file not exist
if not exist "parameters.dat" (
    setlocal disabledelayedexpansion
    echo ! File "parameters.dat" not found
    setlocal enabledelayedexpansion
    goto :exitProgram
)

set VS_dir=
set cpp_standard=
set std_module_support=
set compile_in_new_window=

:: set up the parameters
for /f "usebackq tokens=1* delims==" %%A in ("parameters.dat") do (
    set "tokenStart=%%A"
    :: if not a comment line
    if not "!tokenStart:~0,1!"=="#" (
        set "%%A=%%B"
    )
)

:: if requested to compile in new window
if %compile_in_new_window%==1 (
    if not exist "1800COMPILE.bat" (
        setlocal disabledelayedexpansion
        echo ! Failed to locate compiling script "1800COMPILE.bat" in script directory
        goto :exitProgram
    )
)

:: if the script should compile in the same window or in a new window
:: verify c++ parameters
@REM see: https://learn.microsoft.com/en-us/cpp/build/reference/std-specify-language-standard-version?view=msvc-170&viewFallbackFrom=vs-2019
set /a correct_cpp_standard=0
if "%cpp_standard%"=="c++14" set /a correct_cpp_standard+=1
if "%cpp_standard%"=="c++17" set /a correct_cpp_standard+=1
if "%cpp_standard%"=="c++20" set /a correct_cpp_standard+=1
if "%cpp_standard%"=="c++latest" set /a correct_cpp_standard+=1
if %correct_cpp_standard%==0 (
    setlocal disabledelayedexpansion
    echo ! Unexpected C++ standard ^(requested standard: C++%cpp_standard:~3%^)
    echo ! C++ standards accepted: 14, 17, 20, latest
    goto :exitProgram
)

:: echo parameters
setlocal disabledelayedexpansion
if not exist "%VS_dir%" (
    echo ! Failed to locate Visual Studio folder "VC" based on parameters.dat
    echo ! Provided file path: "%VS_dir%"
    goto :exitProgram
) else (
    echo ! Found file path "%VS_dir%"
    echo ! Using standard: %cpp_standard%
)
setlocal enabledelayedexpansion
echo.

if %compile_in_new_window%==0 (
    :: Set up the Visual Studio environment
    echo Loading environment...
    call "%VS_dir%\Auxiliary\Build\vcvarsall.bat" x64
    if !errorlevel! neq 0 (
        setlocal disabledelayedexpansion
        echo ! Failed to load environment
        goto :exitProgram
    ) else (
        setlocal disabledelayedexpansion
        echo ! Successfully loaded environment
    )
    setlocal enabledelayedexpansion
)

:: fetch the visual studio version by creating a temporary file to fetch the output of the vcvarsall.bat
set "_temp_file=%TEMP%\vcvarsall_output.temp"
if exist "%_temp_file%" del "%_temp_file%"
type nul > "%_temp_file%"
echo ^| Verifying Visual Studio version...
call "%VS_dir%\Auxiliary\Build\vcvarsall.bat" x64 > "%_temp_file%"

for /f "tokens=*" %%A in ('findstr /i "Visual Studio" "%_temp_file%"') do (
    set "vs_output=%%A"
)

:: extract build and version
for /f "tokens=4,8 delims= " %%A in ("!vs_output!") do (
    set /a vs_build=%%A
    set "vs_version=%%B"
)

:: split version number into major and minor
for /f "tokens=1,2 delims=." %%A in ("!vs_version!") do (
    set "vs_version_major=%%A"
    set "vs_version_minor=%%B"
)

set /a vs_version_major=!vs_version_major:~1!
set /a vs_version_minor=!vs_version_minor!

:: warn of potentially outdated Visual Studio
if %vs_build% lss 2019 (
    echo WARNING: Visual Studio !vs_build! may be outdated for this script and unexpected behavior might occur
    echo ^| It is recommended to you update to Visual Studio 2019 or later to support standard C++20
)

:: if using C++20 or later, attempt to support modules
:: if the std module should be supported
if "!cpp_standard:~3!" neq "latest" (
    :: if the requested standard is not the latest
    set /a requested_standard=!cpp_standard:~3,4!
    if !requested_standard! lss 20 (
        :: warn of module support on standards prior to C++ 20
        if "%std_module_support%"=="1" (
            setlocal disabledelayedexpansion
            echo ! std module support requested, but support only works with standard C++20 or later ^(Requested standard: C++%cpp_standard:~3%^)
            echo ^| Skipping std module support...
            setlocal enabledelayedexpansion
        )
        goto :skipModuleSupport
    )
)

:: if the std module even can be supported
@REM see https://learn.microsoft.com/en-us/cpp/cpp/tutorial-import-stl-named-module?view=msvc-170
set /a module_support=0
if "%std_module_support%"=="1" (
    setlocal disabledelayedexpansion
    echo ! Use of module std requires Visual Studio 2022, version 17.5 or later
    setlocal enabledelayedexpansion

    @REM echoes errors, workaround is to let it get stale since it's being made in %TEMP% anyways
    @REM if exist "%_temp_file%" del "%_temp_file%"

    :: verify
    if !vs_build! lss 2022 (
        echo ^| For std module support, please download Visual Studio 2022 or later ^(Your Visual Studio: !vs_build!^)
        goto :skipModuleSupport
    ) else if !vs_version_major! lss 17 (
        goto :outdatedVisualStudio
    ) else if !vs_version_minor! lss 5 (
        :outdatedVisualStudio
        echo ^| For std module support, please update your Visual Studio to version 17.5 or later ^(Your Visual Studio version: !vs_version!^)
        goto :skipModuleSupport
    ) else (
        echo ^| std module is supported for your version of Visual Studio ^(Your Visual Studio: Visual Studio !vs_build! !vs_version!^)
        echo ^| Note: to support the std module the C++ standard will default to C++latest
    )

    :: set up std module support
    set "module_dir=%VS_dir%\Tools\MSVC"
    for /d %%G in ("!module_dir!\*") do (
        set "_temp_dir=%%G"
        if exist "!_temp_dir!\modules\std.ixx" (
            set "module_dir=!_temp_dir!\modules\std.ixx"
            goto :stdFound
        )
    )
    :: failed to find std.ixx
    echo ^| Failed to find std.ixx, std module will not be supported at this time
    echo ^| Did you install C++ Modules build tools? See: https://learn.microsoft.com/en-us/cpp/error-messages/compiler-errors-1/fatal-error-c1011?view=msvc-170
    goto :skipModuleSupport

    :stdFound
    :: compile the standard library named modules into binary form to the same location at this batch script
    echo ^| Compiling std module to "%~dp0"

    cd /d "%~dp0"

    @REM for some reason, when including the switches /Fo and /ifcOutput
    @REM the /ifcOutput will compile out the std.ifc  to the directory file, but the std.obj from /Fo will be nowhere to be found
    @REM cl /std:c++latest /EHsc /nologo /W4 /c "!module_dir!" /Fo""%~dp0\\"" /ifcOutput""%~dp0\\""
    cl /std:c++latest /EHsc /nologo /W4 /c "!module_dir!"


    if errorlevel 1 (
        echo ^| An error occured and the std module will not be supported at this time
        goto :skipModuleSupport
    ) else (
        set /a module_support=1
    )
)
:skipModuleSupport

echo.

:: Prompt for the source directory
:askSourceDirAgain
set /p "source_dir=> Enter source directory: "

:: Remove quotes from source directoryif implemented
set "source_dir=%source_dir:"=%"

if not exist "%source_dir%" (
    echo ^| Directory "%source_dir%" not found, please try again.
    goto :askSourceDirAgain
)
echo ^| Source directory found: "%source_dir%"
echo.

:askSourceFileAgain
set /p "source_file=> Enter cpp file name: "

:: Remove quotes from source file if implemented
set "source_file=%source_file:"=%"

:: assuming the source file is the same as the source file name
set source_file_name=%source_file%

:: if the file name does not contain .cpp extension, append it
:: otherwise set the source file name omitting the extension
echo %source_file%| findstr /i "\.cpp$" >nul
if errorlevel 1 ( 
    set "source_file=%source_file%.cpp"
) else (
    for %%F in ("%source_file%") do set "source_file_name=%%~nF"
)

:: verify source file exists in source directory
if not exist "%source_dir%\%source_file%" (
    echo ^| File "%source_dir%\%source_file%" not found in directory, please try again.
    goto :askSourceFileAgain
)
echo ^| File found: "%source_dir%\%source_file%"

:: if the script should compile in the current working window or in a new window
:recompileProgram
if !compile_in_new_window!==0 (

    :: compile the program
    set "output_dir=%source_dir%\Compiled"
    if not exist "%output_dir%" (
        echo ^|Creating: "%output_dir%"
        mkdir "%output_dir%"
    )
    echo ^| Attempting to compile into: "%output_dir%\%source_file_name%.exe"
    echo.

    echo =====
    echo ==================== COMPILER BEGIN ====================
    :: if modules are supported
    if !module_support!==1 (
        cl /c /reference "std=%~dp0\std.ifc" /std:c++latest /EHsc "!source_dir!\!source_file!" /Fo"!output_dir!\\"
        link  "!output_dir!\!source_file_name!.obj" "%~dp0\std.obj" /OUT:"!output_dir!\!source_file_name!.exe"
    ) else (
        cl /std:!cpp_standard! /EHsc "!source_dir!\!source_file!" /Fo"!output_dir!\\" /Fe"!output_dir!\!source_file_name!.exe"
    )
    echo ====================  COMPILER END  ====================
    echo =====
    echo.

    :: should the program fail to compile
    if !errorlevel! neq 0 (
        color 0c
        :askToRecompileAgain
        setlocal disabledelayedexpansion
        echo ! Program has failed to compile or an error occurred
        setlocal enabledelayedexpansion
        echo 1. Attempt to compile the program again
        echo 2. Choose another program to compile
        set /p choice="> Choice: "
        if "%choice%"=="1" (
            echo.
            color
            goto :recompileProgram
        ) else if "%choice%"=="2" (
            echo.
            color
            goto :askSourceFileAgain
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
    set /p runProgram="> Run the compiled program or recompile? (y/n/r): "
    if /i "%runProgram%"=="y" (
        echo ^| Attempting to run: "%output_dir%\%source_file_name%.exe"
        start "%source_file_name%" /d "%output_dir%" cmd /k "%source_file_name%.exe & pause & exit 0"

    ) else if /i "%runProgram%"=="r" (
        goto :recompileProgram
    ) else if /i not "%runProgram%"=="n" (
        echo ^| Invalid Response, please try again.
        goto :askToRunAgain
    )
    echo.
) else if %compile_in_new_window%==1 (
    echo.
    setlocal disabledelayedexpansion
    echo ! Calling compiling script...
    setlocal enabledelayedexpansion
    start "Compiling Window" cmd /k ^
        "1800COMPILE.bat !module_support! !cpp_standard! ^"!source_dir!^" ^"!source_file!^" ^"!source_file_name!^" ^"!output_dir!^" ^"!VS-dir!^""
)

:: ask the user if they want to recompile, change directory, or exit
:chooseNextStep
echo Choose what to do next
if %compile_in_new_window%==1 echo 1. Re-open compiling window 
if %compile_in_new_window%==0 echo 1. Recompile
echo 2. Choose another program to compile
echo 3. Choose another directory
echo 4. Exit
set /p "choice=> Choice: "

if "%choice%"=="1" (
    goto :recompileProgram
) else if "%choice%"=="2" (
    echo.
    goto :askSourceFileAgain
) else if "%choice%"=="3" (
    echo.
    goto :askSourceDirAgain
) else if "%choice%"=="4" (
    goto :exitProgram
) else (
    echo ^| Invalid response, please try again.
    echo.
    goto :chooseNextStep
)

:exitProgram
setlocal disabledelayedexpansion
echo ! Exiting program...
exit /b 1