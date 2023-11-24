@echo off
setlocal

echo "======Starting set up Microsoft Visual Studio for amd64 architecture..."
CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
echo Exit code was %ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
echo "======Done set up Microsoft Visual Studio for amd64 architecture."

echo "======Starting set up source and build directories..."
set _SRC="%CD%"
set _BUILD_DIR="%CD%\build-Release"

REM Delete any existing build
if exist "%_BUILD_DIR%" (
    rmdir /s /q "%_BUILD_DIR%"
)

REM Create the build directory and navigate to it
mkdir "%_BUILD_DIR%"
cd "%_BUILD_DIR%"

echo Exit code was %ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
echo "======Done set up source and build directories."

echo "======Starting get user input."
set /p PFX_SIGNATURE_KEY=PFX_SIGNATURE_KEY:
set /p PFX_PASSWORD=PFX_PASSWORD:
echo "======Done get user input."

echo "======Starting the CMake command..."
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DAPP_PACKAGE_SIGN=ON -DAPP_BUNDLE=ON -DPFX_SIGNATURE_KEY=%PFX_SIGNATURE_KEY% -DPFX_PASSWORD=%PFX_PASSWORD% -DCMAKE_INSTALL_PREFIX="%_BUILD_DIR%/install" -DCMAKE_INSTALL_BINDIR=bin

echo Exit code was %ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
echo "======Done the CMake command."

echo "======Starting build (ninja)..."
ninja
echo Exit code was %ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
echo "======Done build (ninja)."

echo "======Starting install (ninja)..."
ninja install
echo Exit code was %ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
echo "======Done install (ninja)."

endlocal
@echo on
