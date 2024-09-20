@ECHO OFF
SETLOCAL EnableDelayedExpansion

REM Asistencia Remota con Zero Trust
::    Autor: David Díez @ Zscaler 
::    Fecha: 28 de junio de 2023 
::    Versión: 1.0
::    Name: ZSRA.BAT
::    Descripción: Script para generar una peticion de asistencia remota desde el "user/novice" 
::                 utilizando un FQDN en lugar de la IP del dispositivo.


:: Variables Globales

set domain=YOUR_ACTIVEDIRECTORY_DOMAIN
set novice_dir=C:\YOURDIR\CAU
set expert_dir=\\10.0.0.2\ZSCALER
set novice_invite=%novice_dir%\%computername%.msrcIncident
set expert_invite=%expert_dir%\%computername%.msrcIncident
set expert_bat=%expert_dir%\%computername%.bat
:: Fin Variables Globales

:: ***************
:: **** MAIN *****
:: ***************
echo Running...
del %novice_invite% 2> nul

:: Esperamos hasta que Windows Remote Assistance genere la invitacion
start /b msra.exe /saveasfile %novice_invite%

:waitloop
IF EXIST %novice_invite% GOTO waitloopend
timeout /T 1 /NOBREAK > nul
echo Esperando que MSRA.EXE genere el fichero de invitacion...
goto waitloop
:waitloopend

echo Invitation file CREATED...
echo TRANSFORMING invitation file...
timeout /T 1 /NOBREAK > nul

:: Parseamos el fichero de invitacion
for /f tokens^=8^,10^,12^,14^,16^ delims^=^" %%a in (%novice_invite%) do (
    set RCTICKET=%%a
    set PassStub=%%b
    set RCTICKETENCRYPTED=%%c
    set DtStart=%%d
    set DtLength=%%e
)

:: Obtenemos la IP del dispositivo que sera la que use RPC como Endpoint
for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr [') do set NetworkIP=%%a
::echo Network IP: %NetworkIP%

:: Obtenemos el Full Name del user/novice
for /f "tokens=2*" %%n in ('net user %USERNAME% /domain^|FINDSTR /C:"Full Name"') do set FullName="%%o"
::echo FullName: %FullName%

:: Sustituimos la IP por el FQDN del dispositivo
set NEW_RCTICKET=!RCTICKET:%NetworkIP%=%computername%.%DOMAIN%!

:: Eliminamos ficheros anteriores en las carpetas de Experte y Novice
del %novice_invite% 2> nul
del %expert_invite% 2> nul
del %expert_bat% 2> nul

:: Creamos un nuevo fichero de invitacion sin LHTICKET y con el nuevo RCTICKET
echo ^<?xml version="1.0"?^> > %expert_invite%
echo ^<UPLOADINFO TYPE="Escalated"^>^<UPLOADDATA USERNAME=%FullName% RCTICKET="%NEW_RCTICKET%" PassStub="%PassStub%" RCTIKETENCRYPTED="%RCTICKETENCRYPTED%" DtStart="%DtStart%" DtLength="%DtLength%" L="0"/^>^</UPLOADINFO^> >> %expert_invite%

:: Optativo. Generamos BAT para que el Expert ejecute desde el BAT en lugar desde el fichero de invitacion
:: echo msra.exe /openfile %expert_invite% > %expert_bat%

echo FINISH OK - Invitation file created for EXPERT in %expert_dir%
echo SUCCESS
timeout /T 1 /NOBREAK > nul

EXIT


