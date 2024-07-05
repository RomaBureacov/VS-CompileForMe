# VS CompileForMe
 A batch script for compiling C++ program using Visual Studio's C++ compiler. Created because by default Visual Studio has no way to compile one-off scripts for you without opening its terminal and using `cl /EHsc` for everything, and so that initially became really tedious when attempting to learn C++ through all the little scripts a textbook would provide.

## Setup

*This program assumes you have Visual Studio installed. This script has not been tested outside of the Windows 11 Version 23H2 environment.*

Download the file `CompileForMe.bat` provided in this repository.

Before you start running the program, you must first edit a small portion of the program. You will need to find the location of the Visual Studio C++ environment so that you can compile scripts into executables. The file you are looking for is called `vsvarsall.bat`, and it will be located in approximately the same directory as 

    C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat

Once you find the directory and the file, simply copy it into your clipboard, the full link you are copying should look similar to the one above, and should include the `vsvarsall.bat`.

Next you will need to open the `.bat` file in a text editor. Simply right-click and choose *Edit* or open with your preferred text editor.

You will navigate to one of the very first lines of code that starts with `call`. From here, you will paste your file directory over the one in the script, such that it will call the Visual Studio environment correctly when it comes time to compile.

You have now successfully set up the program and are free to compile your short, one-off scripts!

## Use

Simply follow the instructions the program provides. Note that when it asks for the directory, it is sensitive to spaces, so if your directory includes spaces, *you must enclose the directory in quotes*.

For example, an invalid directory name would be:

    Z:\Documents\My C++\Programs and stuff

Instead you must enclose it in quotes when providing it to the batch script as such:

    "Z:\Documents\My C++\Programs and stuff"

When providing your script name, you may choose to either include or omit the `.cpp` extension.

If the VS compiler fails to compile your C++ program, the script will tell you that it failed to compile and will wait for your response on what to do next (either proceed to recompile or attempt to compile another script).

Once your program compiles successfully, you can choose to run it, move on, or recompile.

At the end, you may choose to either recompile the same script, attempt to compile another script, use another directory, or exit the program.

Have fun programming!