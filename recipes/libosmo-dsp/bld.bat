@echo on

:: reset compiler to m2w64-toolchain since MSVC is also activated
:: (MSVC is needed later to generate the import lib)
set "CC=gcc.exe"

copy "%RECIPE_DIR%\build.sh" .
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
FOR /F "delims=" %%i in ('cygpath.exe -u "%LIBRARY_PREFIX%"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%BUILD_PREFIX%"') DO set "BUILD_PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%SRC_DIR%"') DO set "SRC_DIR=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%RECIPE_DIR%"') DO set "RECIPE_DIR=%%i"
bash -lce "./build.sh"
if errorlevel 1 exit 1

:: Generate MSVC-compatible import library
FOR /F %%i in ("%LIBRARY_PREFIX%/bin/libosmodsp*.dll") DO (
  dumpbin /exports "%%i" > exports.txt
  echo LIBRARY %%~nxi > %%~ni.def
  echo EXPORTS >> %%~ni.def
  FOR /F "skip=19 tokens=4" %%A in (exports.txt) DO echo %%A >> %%~ni.def
  lib /def:%%~ni.def /out:osmodsp.lib /machine:x64
  copy osmodsp.lib "%LIBRARY_PREFIX%/lib/osmodsp.lib"
)
if errorlevel 1 exit 1
