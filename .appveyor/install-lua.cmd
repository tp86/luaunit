REM This is a batch file to help with setting up the desired Lua environment.
REM It is intended to be run as "install" step from within AppVeyor.

REM version numbers and file names for binaries from http://sf.net/p/luabinaries/
set VER_51=5.1.5
set VER_52=5.2.4
set VER_53=5.3.3
set VER_54=5.4.0
set ZIP_51=lua-%VER_51%_Win32_bin.zip
set ZIP_52=lua-%VER_52%_Win32_bin.zip
set ZIP_53=lua-%VER_53%_Win32_bin.zip
set ZIP_54=lua-%VER_54%_Win32_bin.zip
set ZIP_51_64=lua-%VER_51%_Win64_bin.zip
set ZIP_52_64=lua-%VER_52%_Win64_bin.zip
set ZIP_53_64=lua-%VER_53%_Win64_bin.zip
set ZIP_54_64=lua-%VER_54%_Win64_bin.zip
set ZIP_LUAJIT20=LuaJIT-2.0.5
set ZIP_LUAJIT21=LuaJIT-2.1.0-beta3

echo Before goto
goto %LUAENV%
goto error

:lua51
set PRETTY_VERSION='Lua 5.1'
set LUA_BIN_DIR=lua51
set LUA_EXE=lua51\lua5.1.exe
set DL_URL=http://sourceforge.net/projects/luabinaries/files/%VER_51%/Tools%%20Executables/%ZIP_51%/download
set DL_ZIP=%ZIP_51%
goto download_and_intall_lua

:lua51_64
set PRETTY_VERSION='Lua 5.1 - 64 bits'
set LUA_BIN_DIR=lua51-64
set LUA_EXE=lua51-64\lua5.1.exe
set DL_URL=http://sourceforge.net/projects/luabinaries/files/%VER_51%/Tools%%20Executables/%ZIP_51_64%/download
set DL_ZIP=%ZIP_51_64%
goto download_and_intall_lua

:lua52
set PRETTY_VERSION='Lua 5.2'
set LUA_BIN_DIR=lua52
set LUA_EXE=lua52\lua52.exe
set DL_URL=http://sourceforge.net/projects/luabinaries/files/%VER_52%/Tools%%20Executables/%ZIP_52%/download
set DL_ZIP=%ZIP_52%
goto download_and_intall_lua

:lua52_64
set PRETTY_VERSION='Lua 5.2 - 64 bits'
set LUA_BIN_DIR=lua52-64
set LUA_EXE=lua52-64\lua52.exe
set DL_URL=http://sourceforge.net/projects/luabinaries/files/%VER_52%/Tools%%20Executables/%ZIP_52_64%/download
set DL_ZIP=%ZIP_52_64%
goto download_and_intall_lua

:lua53
set PRETTY_VERSION='Lua 5.3'
set LUA_BIN_DIR=lua53
set LUA_EXE=lua53\lua53.exe
set DL_URL=http://sourceforge.net/projects/luabinaries/files/%VER_53%/Tools%%20Executables/%ZIP_53%/download
set DL_ZIP=%ZIP_53%
goto download_and_intall_lua

:lua53_64
set PRETTY_VERSION='Lua 5.3 - 64 bits'
set LUA_BIN_DIR=lua53-64
set LUA_EXE=lua53-64\lua53.exe
set DL_URL=http://sourceforge.net/projects/luabinaries/files/%VER_53%/Tools%%20Executables/%ZIP_53_64%/download
set DL_ZIP=%ZIP_53_64%
goto download_and_intall_lua

:lua54
set PRETTY_VERSION='Lua 5.4'
set LUA_BIN_DIR=lua54
set LUA_EXE=lua54\lua54.exe
set DL_URL=http://sourceforge.net/projects/luabinaries/files/%VER_54%/Tools%%20Executables/%ZIP_54%/download
set DL_ZIP=%ZIP_54%
goto download_and_intall_lua

:lua54_64
set PRETTY_VERSION='Lua 5.4 - 64 bits'
set LUA_BIN_DIR=lua54-64
set LUA_EXE=lua54-64\lua54.exe
set DL_URL=http://sourceforge.net/projects/luabinaries/files/%VER_54%/Tools%%20Executables/%ZIP_54_64%/download
set DL_ZIP=%ZIP_54_64%
goto download_and_intall_lua


:luajit20
echo luajit20
set PRETTY_VERSION='LuaJIT 2.0'
set LUA_BIN_DIR=luajit20
set LUA_EXE=luajit20\luajit.exe
set DL_ZIP=LuaJIT-2.0.5
set DL_URL=http://luajit.org/download/%DL_ZIP%.zip
goto download_and_intall_luajit


:luajit21
set PRETTY_VERSION='LuaJIT 2.1'
set LUA_BIN_DIR=luajit21
set LUA_EXE=luajit21\luajit.exe
set DL_ZIP=LuaJIT-2.1.0-beta3
set DL_URL=http://luajit.org/download/%DL_ZIP%.zip
goto download_and_intall_luajit


:download_and_intall_lua
echo Setting up %PRETTY_VERSION% ...
if NOT EXIST %LUA_EXE% (
    @echo on
    echo Fetching %PRETTY_VERSION% from internet
    curl -fLsS -o %DL_ZIP% %DL_URL%
    unzip -d %LUA_BIN_DIR% %DL_ZIP%
) else (
    echo Using cached version of %PRETTY_VERSION
)
set LUA=%LUA_EXE%
goto :eof

:download_and_intall_luajit
echo download and install luajit
echo on
if NOT EXIST %LUA_EXE% (
    echo Downloading %PRETTY_VERSION% ...
    REM Do a minimalistic build of LuaJIT using the MinGW compiler

    REM retrieve and unpack source
    curl -fLsS -o %DL_ZIP%.zip %DL_URL%
    unzip -q %DL_ZIP%

    echo Compiling %PRETTY_VERSION% ...
    set PATH="C:\MinGW\bin;%PATH%"

    REM tweak Makefile for a static LuaJIT build (Windows defaults to "dynamic" otherwise)
    sed -i "s/BUILDMODE=.*mixed/BUILDMODE=static/" %DL_ZIP%\src\Makefile

    mingw32-make TARGET_SYS=Windows -C %DL_ZIP%\src

    echo Installing %PRETTY_VERSION% ...
    REM copy luajit.exe to project dir
    mkdir %APPVEYOR_BUILD_FOLDER%\%LUA_BIN_DIR%
    copy %DL_ZIP%\src\luajit.exe %APPVEYOR_BUILD_FOLDER%\%LUA_BIN_DIR%\

    REM clean up (remove source folders and archive)
    rm -rf %DL_ZIP%/*
    rm -f %DL_ZIP%.zip
) else (
    echo Using cached version of %PRETTY_VERSION%
)
set LUA=%LUA_EXE%
goto :eof

:error
echo Do not know how to install %LUAENV%
