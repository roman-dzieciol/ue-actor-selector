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
ECHO * UnrealEd plugin uninstall script.
ECHO * Copyright 2005 Roman Switch` Dzieciol, neai o2.pl
ECHO * http://wiki.beyondunreal.com/wiki/Switch
ECHO * **************************************************************************** 
ECHO.


TITLE UNINSTALL :: %PRODUCT%
%PRD_SYS%\ucc.exe %PRODUCT%.%PRODUCT%Setup RemovePackage="%PRODUCT%"
IF ERRORLEVEL 0 GOTO SUCCESS


TITLE WARNING :: %PRODUCT%
ECHO.
ECHO *
ECHO * Failed to remove %PRODUCT% from your EditPackages. Remove it manually.
ECHO * Instructions: http://wiki.beyondunreal.com/wiki/Add_EditPackage
ECHO *
ECHO.
PAUSE


:SUCCESS
DEL /F %PRD_HLP%\%PRODUCT%.txt

DEL /F %PRD_SYS%\%PRODUCT%.u
DEL /F %PRD_EDT%\%PRODUCT%.bmp

DEL /F %PRD_CLS%\%PRODUCT%.uc
DEL /F %PRD_CLS%\%PRODUCT%Proxy.uc
DEL /F %PRD_CLS%\%PRODUCT%Setup.uc

DEL /F %PRD_RES%\compile.ini
DEL /F %PRD_RES%\icon.bmp
DEL /F %PRD_RES%\help.txt

DEL /F %PRD_DIR%\%PRODUCT%\Install.bat

RMDIR %PRD_CLS%
RMDIR %PRD_RES%

ECHO DEL /F %PRODUCT%\Uninstall.bat>%PRD_DIR%\%PRODUCT%Uninstall.bat
ECHO RMDIR %PRODUCT%>>%PRD_DIR%\%PRODUCT%Uninstall.bat
ECHO DEL /F %PRODUCT%Uninstall.bat>>%PRD_DIR%\%PRODUCT%Uninstall.bat

CD %PRD_DIR%
%PRODUCT%Uninstall.bat