@echo off

setlocal

rem $Id: ddkbuild_start.bat,v 1.8 2006-04-05 20:32:15 wmsr Exp $

rem These have to be adapted on your environment
rem I'm assuming DDKBUILD.BAT, Version 5.3
rem It can be downloaded from http://www.osronline.com/article.cfm?article=43
rem Furthermore, I have patched it with patch_ddkbuild.diff to show an error summary
rem after doing its job, but this is not necessary if you do not like.
rem
rem Another option is to use DDKBUILD from Hollies Technologies,
rem downloadable from ...
rem To use that one, just define DDKBUILD_HOLLIS to be 1 on startup.

set CBM4WIN_SRC_HOME=%0\..\..

rem set default local settings (not controlled by CVS)
if exist %CBM4WIN_SRC_HOME%\..\DDKBUILD_LOCAL.BAT call %CBM4WIN_SRC_HOME%\..\DDKBUILD_LOCAL.BAT %CBM4WIN_SRC_HOME%

rem Set this to 1 if you are using DDKBUILD.BAT from Hollis Technology
rem Solutions.  Do not set if using DDKBUILD from OSR
if not defined DDKBUILD_HOLLIS set DDKBUILD_HOLLIS=0

rem First, we have to tell DDKBUILD where all the DDKs are located:

if not defined BASEDIR  set BASEDIR=c:\WINDDK\nt4.ddk
if not defined W2KBASE  set W2KBASE=
if not defined WXPBASE  set WXPBASE=c:\WINDDK\2600
if not defined WNETBASE set WNETBASE=c:\WINDDK\3790

rem After building the driver, the PDB debugging symbols file will be copied
rem to this location here (leave empty of no copying is to be done):

if not defined COPYSYM set COPYSYM=

rem After building the driver, the executable files will be copied
rem to this location here (leave empty of no copying is to be done):

if not defined COPYTARGET set COPYTARGET=

rem Additional arguments for DDKBUILD:
if not defined CMDARGUMENTS set CMDARGUMENTS=


rem Some files which might be useful
if not defined DDKBUILD_CMD_HOLLIS set DDKBUILD_CMD_HOLLIS=ddkbuild_hollis.bat
if not defined DDKBUILD_CMD_OSR    set DDKBUILD_CMD_OSR=ddkbuild_osr.bat

rem --------------------------------------------------------------------------

rem Here, the skript starts. DO NOT CHANGE ANYTHING below this point if you're
rem not totally sure what you're doing.

for /f "tokens=2" %%f in ("%CBM4WIN_SRC_HOME%") do (
	echo ERROR: The calling path to this script contains spaces
	echo.	%0
	echo.
	echo This cannot be handled by ddkbuild.bat -- OSR as well as Hollis. Please
	echo CD into the directory containing ddkbuild_start.bat and start from there
	endlocal
	exit /b 1
	)

shift

rem first, check if we want to use a specific version of ddkbuild

if /I "%0" EQU "-hollis" (
	set DDKBUILD=%DDKBUILD_CMD_HOLLIS%
	set DDKBUILD_HOLLIS=1
	shift
) else if /I "%0" EQU "-osr" (
	set DDKBUILD=%DDKBUILD_CMD_OSR%
	set DDKBUILD_HOLLIS=0
	shift
)

set DDKBUILD_PLATFORM=i386
set OPTIONAL_DIRS=vdd nt4 win98

if %DDKBUILD_HOLLIS% EQU 1 (
	set DDKBUILD_PLATFORM_OPTION=W2K
) else (
	set DDKBUILD_PLATFORM_OPTION=2K
)


if /I "%0" EQU "-i386" (
	shift
) else if /I "%0" EQU "-ia64" (
	set DDKBUILD_PLATFORM=ia64
	set DDKBUILD_PLATFORM_OPTION=64
	set OPTIONAL_DIRS=
	shift
) else if /I "%0" EQU "-amd64" (
	set DDKBUILD_PLATFORM=amd64
	if %DDKBUILD_HOLLIS% EQU 0 (
		echo "AMD64 only with DDKBUILD FROM HOLLIS!"
		exit
	)
	set DDKBUILD_PLATFORM_OPTION=A64
	set OPTIONAL_DIRS=
	shift
)

rem Now, adjust the parameters for the DDKBUILD
rem version we are using
if %DDKBUILD_HOLLIS% EQU 1 (
	set DDKBUILD=%DDKBUILD_CMD_HOLLIS%
	set TARGETSPEC=-WNET%DDKBUILD_PLATFORM_OPTION%
	set CHECKEDFREE=checked
	if /i "%0" EQU "fre" set CHECKEDFREE=free
) else (
	set DDKBUILD=%DDKBUILD_CMD_OSR%
	set TARGETSPEC=-WNET%DDKBUILD_PLATFORM_OPTION%
	set CHECKEDFREE=chk
	if /i "%0" EQU ="fre" set CHECKEDFREE=fre
)

shift

if exist %CBM4WIN_SRC_HOME%\mnib36 set CMDARGUMENTS=%CMDARGUMENTS% mnib36

set CMDLINE=%TARGETSPEC% %DDKBUILD_ARGUMENTS% %CHECKEDFREE% %CBM4WIN_SRC_HOME% %OPTIONAL_DIRS% %0 %1 %2 %3 %4 %5 %6 %7 %8 %9 %CMDARGUMENTS% -F

rem Make sure no error files are present before starting!
if exist build*.err del build*.err

echo CMDLINE="%CMDLINE%"
echo COPYTARGET="%COPYTARGET%"

call %DDKBUILD% %CMDLINE%

rem Copy the INF file into the bin directory
copy %CBM4WIN_SRC_HOME%\sys\wdm\*.inf %CBM4WIN_SRC_HOME%\bin\%DDKBUILD_PLATFORM%

if not exist build*.err (

	rem If we are not called from the root, do not copy!
	if exist ddkbuild_start.bat (

		if "%COPYTARGET%" NEQ "" (
			echo.
			echo =============== copying files to target =============

			xcopy /y %CBM4WIN_SRC_HOME%\bin\%DDKBUILD_PLATFORM%\*.inf %COPYTARGET%\%DDKBUILD_PLATFORM%\
			if errorlevel 1 echo "ddkbuild.bat(1) : error : could not copy INF file to %COPYTARGET%"
			xcopy /y %CBM4WIN_SRC_HOME%\bin\%DDKBUILD_PLATFORM%\*.sys %COPYTARGET%\%DDKBUILD_PLATFORM%\
			if errorlevel 1 echo "ddkbuild.bat(1) : error : could not copy SYS files to %COPYTARGET%"
			xcopy /y %CBM4WIN_SRC_HOME%\bin\%DDKBUILD_PLATFORM%\*.exe %COPYTARGET%\%DDKBUILD_PLATFORM%\
			if errorlevel 1 echo "ddkbuild.bat(1) : error : could not copy EXE files to %COPYTARGET%"
			xcopy /y %CBM4WIN_SRC_HOME%\bin\%DDKBUILD_PLATFORM%\*.dll %COPYTARGET%\%DDKBUILD_PLATFORM%\
			if errorlevel 1 echo "ddkbuild.bat(1) : error : could not copy DLL files to %COPYTARGET%"
		)

		if "%COPYSYM%" NEQ "" (
			echo Copying debugging information
			xcopy /y %CBM4WIN_SRC_HOME%\bin\%DDKBUILD_PLATFORM%\*.pdb %COPYSYM%
			if errorlevel 1 echo "ddkbuild.bat(1) : error : could not copy PDB files for debugging %COPYSYM%"
		)
	)
)

endlocal
