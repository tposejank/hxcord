@echo off

if "%1" == "-hl" (
    echo Compiling to HashLink
    haxe --hl bin/script.hl --main Main --class-path src
    hl bin/script.hl
) else if "%1" == "-neko" (
    echo Compiling to Neko
    haxe --neko bin/script.n --main Main --class-path src
    neko bin/script.n
) else if "%1" == "-cpp" (
    echo Compiling to C++ - HXCPP
    haxe --cpp bin/cpp --main Main --class-path src
    bin\cpp\Main.exe
) else (
    echo Invalid target, Use either of: -hl -neko -cpp
)