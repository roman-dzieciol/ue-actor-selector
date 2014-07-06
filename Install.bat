@ECHO OFF

SET PRODUCT=ActorSelector
SET PRD_UCC=%PRODUCT%UCC
SET PRD_DIR=..
SET PRD_CLS=%PRD_DIR%\%PRODUCT%\Classes
SET PRD_RES=%PRD_DIR%\%PRODUCT%\res
SET PRD_SYS=%PRD_DIR%\System
SET PRD_EDT=%PRD_SYS%\editorres
SET PRD_HLP=%PRD_DIR%\Help

ECHO.
ECHO * ****************************************************************************
ECHO * UnrealEd plugin install script.
ECHO * Copyright 2005 Roman Switch` Dzieciol, neai o2.pl
ECHO * http://wiki.beyondunreal.com/wiki/Switch
ECHO * **************************************************************************** 
ECHO.

TITLE UCC :: %PRODUCT%
ECHO.
ECHO *
ECHO * Preparing compiler environment
ECHO *
ECHO.

COPY /Y %PRD_RES%\compile.ini %PRD_SYS%\%PRD_UCC%.ini
ECHO %PRODUCT%>>%PRD_SYS%\%PRD_UCC%.ini


TITLE UCC :: %PRODUCT%
ECHO.
ECHO *
ECHO * Creating %PRODUCT%.u file
ECHO *
ECHO.

DEL /F %PRD_SYS%\%PRODUCT%.u
%PRD_SYS%\ucc.exe make -INI=%PRD_UCC%.ini
IF ERRORLEVEL 1 GOTO FAIL_UCC


TITLE SETUP :: %PRODUCT%
ECHO.
ECHO *
ECHO * Copying resources
ECHO *
ECHO.

COPY /Y %PRD_RES%\icon.bmp %PRD_EDT%\%PRODUCT%.bmp
COPY /Y %PRD_RES%\help.txt %PRD_HLP%\%PRODUCT%.txt


TITLE SETUP :: %PRODUCT%
ECHO.
ECHO *
ECHO * Adding %PRODUCT%.u to EditPackages
ECHO *
ECHO.

%PRD_SYS%\ucc.exe %PRODUCT%.%PRODUCT%Setup AddPackage="%PRODUCT%"
IF ERRORLEVEL 1 GOTO FAIL_SETUP


TITLE SUCCESS :: %PRODUCT%
ECHO.
ECHO *
ECHO * Done. 
ECHO *
ECHO.
GOTO CLEANUP


:FAIL_SETUP
TITLE WARNING :: %PRODUCT%
ECHO.
ECHO *
ECHO * Setup failed. Add %PRODUCT% to your EditPackages manually.
ECHO * Instructions: http://wiki.beyondunreal.com/wiki/Add_EditPackage
ECHO *
ECHO.
GOTO CLEANUP


:FAIL_UCC
TITLE UCC ERROR :: %PRODUCT%
ECHO.
ECHO *
ECHO * Error!
ECHO *
ECHO.
GOTO CLEANUP


:CLEANUP
DEL /F %PRD_SYS%\%PRD_UCC%.ini
GOTO DISPLAY


:DISPLAY
PAUSE