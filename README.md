# VS CompileForMe
 A batch script for compiling C++ program using Visual Studio's C++ compiler. Created because by default Visual Studio has no way to compile one-off scripts for you without opening its terminal and using `cl /EHsc` for everything, and so that initially became really tedious when attempting to learn C++ through all the little scripts a textbook would provide.

## Setup

*This program assumes you have Visual Studio installed. This script has not been tested outside of the Windows 11 Version 23H2 environment.*

Download the Batch script `CompileForMe.bat` provided in this repository.

**Before you start running the script, you must first edit a small portion of it.**

You will need to find the location of the Visual Studio C++ environment so thatthe script can compile your C++ programs into executables. The file you are looking for is called `vsvarsall.bat`, and it will be located in *approximately* the same directory as 

    C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat

Once you find the directory of the file, simply copy the directory into your clipboard; the full link you are copying should look similar to the one above, and should include the `vcvarsall.bat`.

Next you will need to open the Batch script you downloaded from this repository, `CompileForMe.bat`, in a text editor. Simply right-click it and choose *Edit* to open it in Notepad or open it with your preferred text editor.

You will navigate to one of the very first lines of code that starts with the command `call`. From here, you will paste the directory of `vcvarsall.bat` over the one in the script, such that the script can call the Visual Studio environment correctly when it comes time to compile your C++ programs.

The resulting line should look something similar to the following:

    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64

You have now successfully set up the program and are free to compile your short, one-off scripts!

## Use

Simply follow the instructions the program provides. 

When the program prompts for the directory, quotations are optional.

For example, both of the following would be valid source directories to provide to the program:

    Z:\Documents\My C++\Programs and stuff
    "Z:\Documents\My C++\Programs and stuff"

When providing your script name, the `.cpp` extension is optional. Quoting is also optional. The file name you provide is also *case in-sensitive*.

All of the following would be valid file names to provide to the script (assuming the source file is named `Program 8-34.cpp`):

    Program 8-34
    Program 8-34.cpp
    "Program 8-34"
    "Program 8-34.cpp"

Should the VS compiler fail to compile your C++ program, the script will notify you and will await your response on what to do next (either attempt to compile again or attempt to compile another script).

Once your program compiles successfully, you can choose to run it, move on, or recompile.

If you choose to run the program, it will open in a new cmd window. Upon the compiled program's termination, you can either close the window with the mouse or simply type the command `exit` into the terminal.

At the end of the script, you may choose to either recompile the same script, attempt to compile another script, use another directory, or exit the program.

Have fun programming!