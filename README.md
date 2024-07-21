# VS CompileForMe
 A batch script for compiling C++ program using Visual Studio's C++ compiler. Created because by default Visual Studio has no way to compile one-off scripts for you without opening its terminal and using `cl /EHsc` for everything, and so that initially became really tedious when attempting to learn C++ through all the little scripts a textbook would provide.
 
Found a new textbook to learn C++ from (*Principles and Practice Using C++* by Bjarne Stroustrup, creator of C++), so now the script supports C++20 and later `std` module.

## Setup

*This program assumes you have Visual Studio installed. This script has not been tested outside of the Windows 11 Version 23H2 nor for Visual Studio 2017 or before.*

*It is highly recommended to use the latest version of Visual Studio 2022 for this script.*

Download the all files located in *Required Files*.

**Before you start running the script, you must first edit `parameters.dat`.**

You will need to find the location of the Visual Studio folder *VC*, located in approximately the location:

    C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC
    
Your directory may look different if you did a custom installation. For example, my directory looks something like this (for Visual Studio 2022):

    Z:\Applications\Visual Studio IDE\VC

Once you find the directory of the folder, simply copy the directory into your clipboard: right-click the folder and choose "Copy as path."

Next you will need to open the file `parameters.dat` in a text editor. Simply right-click it and choose *Edit* to open it in Notepad or open it with your preferred text editor.

You will navigate to the variable `VS_dir` and paste your directory in there. The resulting line should look somewhat similar to this (note the omission of quotation marks, you must remove the quotation marks):

    VS_dir=Z:\Applications\Visual Studio IDE\VC

You have now successfully set up the program and are free to compile your short, one-off scripts!

## Use

### General

Simply follow the instructions the program provides. 

When the program prompts for the source directory, quotations are optional and spaces are handled automatically. The source directory you provide is also *case in-sensitive*.

For example, both of the following would be valid source directories to provide to the program:

    Z:\Documents\My C++\Programs and stuff
    "Z:\Documents\My C++\Programs and stuff"

When providing your script name, the `.cpp` extension is optional. Quoting is also optional. The file name you provide is also *case in-sensitive*.

All of the following would be valid file names to provide to the script (assuming the source file is named `Program 8-34.cpp`):

    Program 8-34
    Program 8-34.cpp
    "Program 8-34"
    "Program 8-34.cpp"

Should the VS compiler fail to compile your C++ program, the script will notify you and will await your response on what to do next (either attempt to compile again or attempt to compile another script). If you have enabled compiling in a new window, the new window will notify you of any failures in compilation.

Once your program compiles successfully, you may choose to run it, move on, or recompile.

If you choose to run the program, it will open in a new `cmd` window. Upon the compiled program's termination, ther window will pause and then exit once you continue.

At the end of the script, you may choose to either recompile the same script (or call the compiling window again if you enabled compiling in a new window), attempt to compile another script, use another directory, or exit the program.

### `parameters.dat` File

This file is meant to allow for a little bit of customization to the script. The options include:

|Variable|Possible Arguments|Notes|
|:-:|:-:|:-:|
|`VS_dir`| *file path* | Directory leading to the folder *VC* in the Visual Studio installation
|`cpp_standard`|14, 17, 20, latest | C++ standard for the compiler to use |
|`std_module_support`| 0, 1 | disable or enable, respecively, support of the module `std` (note: modules are a part of standard C++20 and later. For module support, the compiler will default to standard C++latest)|
|`compile_in_new_window`| 0, 1 | disable or enable, respectively, compiling in a new window. This simply toggles whether if you want the compiler to work in the same window as the running script or in a new window. Useful for reducing clutter of text and makes debugging a little easier. |

# FIN

Have fun programming!