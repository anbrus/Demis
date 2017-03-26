@echo off

:devdir
call %MSDEVDIR%\bin\vcvars32 x86
if "%MSVCDIR%"=="" set MSVCDIR=%MSDEVDIR%

:testbasedir

if "%BASEDIR%"=="" goto setbasedir
if NOT "%BASEDIR%"=="D:\98ddk" goto setbasedir

set Path=%BASEDIR%\bin;%path%
set Lib=%BASEDIR%\lib;%lib%
set Include=%BASEDIR%\inc;%BASEDIR%\inc\win98;%include%

if "%DDKBUILDENV%"=="" goto setenv
if NOT "%DDKBUILDENV%"=="checked" goto envtest
goto done

:setbasedir

rem set BASEDIR to ddk directory and set path to point to ddk binaries

set BASEDIR=D:\98ddk
set Path=D:\98ddk\bin;D:\98ddk\bin\win98;%path%
set Lib=D:\98ddk\lib;%lib%
set Include=D:\98ddk\inc;D:\98ddk\inc\win98;%include%

:setenv

call %BASEDIR%\bin\dvol
set NTMAKEENV=%BASEDIR%\inc
set BUILD_MAKE_PROGRAM=nmake.exe
set BUILD_DEFAULT=-ei -nmake -i

if "%tmp%"=="" set tmp=\

if "%PROCESSOR_ARCHITECTURE%"=="x86" goto i386
set PROCESSOR_ARCHITECTURE=x86
goto i386

@rem if "%PROCESSOR_ARCHITECTURE%"=="" goto cpuerror
@rem if "%PROCESSOR_ARCHITECTURE%"=="ALPHA" goto alpha
@rem if "%PROCESSOR_ARCHITECTURE%"=="MIPS" goto mips
@rem if "%PROCESSOR_ARCHITECTURE%"=="x86" goto i386
@rem if "%PROCESSOR_ARCHITECTURE%"=="PPC" goto ppc

@rem goto cpuerror

:alpha

if "%Cpu%" == "" set Cpu=ALPHA
set BUILD_DEFAULT_TARGETS=-alpha
set ALPHA=1
set JENSEN=1
set NTALPHADEFAULT=1

goto envtest

:ppc

if "%Cpu%" == "" set Cpu=PPC
set BUILD_DEFAULT_TARGETS=-ppc
set PPC=1
set _PPC_=1
set NTPPCDEFAULT=1

goto envtest

:mips

if "%Cpu%" == "" set Cpu=MIPS
set BUILD_DEFAULT_TARGETS=-mips
set MIPS_R4000=1
set _JAZZIDW=1
set NTMIPSDEFAULT=1

goto envtest

:i386

if "%Cpu%" == "" set Cpu=i386
set BUILD_DEFAULT_TARGETS=-386

:envtest

if "checked"=="" goto free
if "checked"=="free" goto free
if "checked"=="FREE" goto free
if "checked"=="checked" goto checked
if "checked"=="CHECKED" goto checked
goto usage

:free

rem set up an NT free build environment

set DDKBUILDENV=free
set C_DEFINES=-D_IDWBUILD
set NTDBGFILES=1
set NTDEBUG=
set NTDEBUGTYPE=
set MSC_OPTIMIZATION=

goto done

:checked

rem set up an NT checked build environment

set DDKBUILDENV=checked
set C_DEFINES=-D_IDWBUILD -DRDRDBG -DSRVDBG
set NTDBGFILES=
set NTDEBUG=ntsd
set NTDEBUGTYPE=both
set MSC_OPTIMIZATION=/Od /Oi

:done

set _OBJ_DIR=obj
set NEW_CRTS=1
IF "%_NTROOT%"==""  set _NTROOT=%BASEDIR%

doskey /macrofile=%BASEDIR%\bin\generic.mac

if "%DDKDRIVE%"=="" goto noddkdrive

doskey /macrofile=%BASEDIR%\bin\ddktree.mac
cd %BASEDIR%
%DDKDRIVE%
goto end

:noddkdrive

cd /d %BASEDIR%
goto end

:cpuerror

echo.
echo Error: PROCESSOR_ARCHITECTURE environment variable not recognized.
echo.
echo.

goto end

:no_msvc40
@echo Error: MSDEVDIR environment variable not recognized.
@echo        MS VC++ 4.0, 4.1, or 4.2 must be installed.

goto end

:usage

echo.
echo usage: setenv ^<directory^> [free^|^checked]
echo.
echo   Example:  setenv d:\ddk checked     set checked environment
echo   Example:  setenv d:\ddk             defaults to free environment
echo.
echo.


:end
