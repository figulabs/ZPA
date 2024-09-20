Zscaler Remote Assitance (ZSRA)
---------------------------------

Script para generar una petición de asistencia remota Windows desde el "user/novice" utilizando un FQDN del dispositivo en lugar de la IP del dispositivo
   - Con ZPA no existen direcciones ip internas y la asistencia remota de Windows cuando crea un fichero de invitación lo hace con la IP privada del dispositivo. De este modo ZPA Cliente-To-Client no funcionaría
   - El script genera el fichero de invitación utilizando el ejecutable de windows "msra.exe" y posteriormente lo modifica. 
   - Entre otras cosas el script sustituye la IP Privada por el FQDN del dispositivo 
   - También se elimina el LHTICKET de la invitación y se modifica el RCTICKET con el FQDN

Modificar las variables globales dentro del BAT antes de ejecutarlo

:: Variables Globales

set domain=YOUR_ACTIVEDIRECTORY_DOMAIN    <<<< Dominio Active Directory
set novice_dir=C:\YOURDIR\CAU <<< directorio temporal donde se guarda el fichero de invitación ya modificado con el FQDN
set expert_dir=\\10.0.0.2\ZSCALER  <<<< directorio donde se movera el fichero de invitación para que los Expert/Admins puedan tomar el control de user/novice

Flujo de operación sería
1. Un usuario necesita asistencia remota y ejecuta ZSRA.bat
2. El script genera un fichero de invitación y lo guarda en un directorio compartido accesible por los usuarios y los administradores (expert_dir)
3. El usuario abre un ticket en la herramienta de ticketing de la compañía
4. Cuando el expert/Admin recibe el ticket sabe el nombre del computador del usuario y accede al directorio <expert_dir> para ejecutar el fichero de invitación remota
