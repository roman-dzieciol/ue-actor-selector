@ECHO off

SET PRODUCT=ActorSelector
SET PRD_REV=BETA1
SET PRD_DIR=..\..\..
SET PRD_SYS=%PRD_DIR%\System
SET PRD_HLP=%PRD_DIR%\Help
SET PRD_RES=%PRD_DIR%\%PRODUCT%\res
SET PRD_MAN=Manifest
SET PRD_MBK=%PRD_MAN%Backup
SET PRD_UMD=%PRODUCT%UMOD
SET PRD_REL=%PRODUCT%%PRD_REV%


ECHO.
ECHO * ****************************************************************************
ECHO * UnrealEd plugin umod script.
ECHO * Copyright 2005 Roman Switch` Dzieciol, neai o2.pl
ECHO * http://wiki.beyondunreal.com/wiki/Switch
ECHO * **************************************************************************** 
ECHO.

TITLE UMOD :: %PRD_UMD%
ECHO.
ECHO *
ECHO * Preparing umod configuration
ECHO *
ECHO.

COPY /Y %PRD_SYS%\%PRD_MAN%.ini %PRD_MBK%.ini
COPY /Y umod.ini %PRD_SYS%\%PRD_UMD%.ini
COPY /Y umod.int %PRD_SYS%\%PRD_UMD%.int


TITLE UMOD :: %PRD_UMD%
ECHO.
ECHO *
ECHO * Creating %PRODUCT%.urm file
ECHO *
ECHO.

%PRD_SYS%\ucc.exe master %PRD_UMD%
IF ERRORLEVEL 1 GOTO FAIL_MASTER


TITLE COPY :: %PRD_UMD%
ECHO.
ECHO *
ECHO * Copying release files
ECHO *
ECHO.

RD /S /Q %PRD_REL%
MD %PRD_REL%
COPY /Y %PRODUCT%.urm %PRD_REL%\%PRD_REL%.urm
COPY /Y %PRD_RES%\help.txt %PRD_REL%\%PRODUCT%.txt
XCOPY /Y /I /E /Q %PRD_DIR%\%PRODUCT% %PRD_REL%\%PRODUCT%\

GOTO CLEANUP


:FAIL_MASTER
TITLE ERROR :: %PRD_UMD%
ECHO.
ECHO *
ECHO * UMOD creation failed.
ECHO *
ECHO.
GOTO CLEANUP


:CLEANUP
DEL /F %PRD_SYS%\%PRD_MAN%.int
DEL /F %PRD_SYS%\%PRD_UMD%.int
DEL /F %PRD_SYS%\%PRD_UMD%.ini
COPY /Y %PRD_MBK%.ini %PRD_SYS%\%PRD_MAN%.ini
DEL /F %PRD_MBK%.ini

ECHO.
PAUSE