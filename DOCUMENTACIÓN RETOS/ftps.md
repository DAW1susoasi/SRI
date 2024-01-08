#Servicio de Hosting
***
Vamos a instalar un servidor ftps explícito en modo pasivo, enjaulando a los usuarios locales en ~/public_html y forzando el uso del protocolo FTPS  
- ¿Por qué modo pasivo y no activo? En el modo activo el cliente solicita el servidor, enviando un comando PORT, a través de un puerto aleatorio superior al 1023 (por ejemplo el 1500) por el canal de control, con un paquete dirigido al puerto 21 del servidor, a fin de por ejemplo transferir un archivo.  
Una vez establecida la conexión, el servidor **inicia otra** a través del puerto 20 por el canal de datos con el puerto siguiente del cliente, es decir, el 1501, por lo que tendríamos que abrir dicho puerto en el cliente.  
En el modo pasivo el cliente también se pone en contacto con el puerto 21 del servidor FTP a través de un comando PASV. En lugar de iniciar una segunda conexión de inmediato, el servidor responde que el cliente sólo puede ponerse en contacto con un segundo puerto diferente a la primera. Se realiza una segunda conexión entre el cliente y el servidor por el canal de datos pero esta vez **iniciada por el cliente**, por lo que tenemos que abrir en el servidor el puerto 21 para el canal de control y un rango de puertos a partir del 1023 para el canal de datos.  
- ¿Qué significa enjaular a los usuarios locales? Cuando los usuarios locales del equipo servidor se conecten, sólo tendrán acceso a la carpeta de conexión, en este caso `'public_html'` situada dentro de su directorio personal.  
- ¿Por qué ftps explícito? [FTPS](https://es.wikipedia.org/wiki/FTPS) es junto con [SFPT](https://es.wikipedia.org/wiki/SSH_File_Transfer_Protocol) ([SSH](https://es.wikipedia.org/wiki/SSH) sobre FTP) una forma segura de conexión FTP en el que se usa de una capa [SSL/TLS](https://es.wikipedia.org/wiki/Transport_Layer_Security) debajo del protocolo estándar [FTP](https://es.wikipedia.org/wiki/File_Transfer_Protocol) para cifrar los canales de control y/o datos.  
    Explícito y no implícito es porque implícito (se realiza una negociación SSL, normalmente a través del puerto 990, antes de que se envíe cualquier comando FTP) está anticuado, aunque no en deshuso.  

Instalación y configuración:  
1. Instalación  del servidor
    Vamos a instalar  [vsftpd](https://security.appspot.com/vsftpd.html) porque es el más extendido en sistemas Unix/Linux, cumple nuestros requisitos y además se jacta de ser el servidor FTP más seguro.  
    ```
    apt install vsftpd
    ```
2. Configuración: basada en la edición del archivo /etc/vsftpd.conf  
    - Configuraciones generales
        No habilitamos el acceso anónimo (el usuario anónimo se corresponde con el usuario local ftp, que por defecto sólo tiene permisos de lectura en el directorio /srv/ftp, NO PODRÁ ACCEDER):  
        ```
        anonymous_enable=NO
        ```
        Permitimos la descarga de archivos:  
        ```
        download_enable=YES
        ```
        Mostramos un mensaje de bienvenida al cliente cuando conecta (sólo para despistados):  
        ```
        ftpd_banner=Bienvenido al servidor FTP de Marchante
        ```
        En el modo pasivo el puerto 20 para el canal de datos no se usa:  
        ```
        connect_from_port_20=NO
        ```
        Si queremos automatizar la creación de la carpeta ``public_html`` en el ``home`` del usuario tras añadirlo al sistema:  
        ```
        mkdir /etc/skel/public_html
        ```
    - Configuración del modo pasivo
        Habilitamos el modo pasivo y establecemos el rango de puertos para el canal de datos:
        ```
        pasv_enable=YES
        pasv_min_port=40000
        pasv_max_port=40100
        ```
    - Configuración de los usuarios locales  
        Permitimos que puedan conectarse:  
        ```
        local_enable=YES
        ```
        Permitimos la escritura:  
        ```
        write_enable=YES
        ```
        Eliminamos (umask) permiso de escritura (2) al grupo y a otros usuarios, quedando al final permisos 644, o sea, el propietario podrá leer y escribir, y el grupo y otros usuarios sólo podrán leer:  
        ```
        local_umask=022
        ```
        Enjaulamos a los usuarios locales dentro de su propio directorio personal para que no puedan navegar fuera de éste:  
        ```
        chroot_local_user=YES
        ```
        Establecemos que el directorio personal del usuario va a ser el subdirectorio ``public_html`` de su ``home``:  
        ```
        user_sub_token=$USER
        local_root=/home/$USER/public_html
        ```
        No es el caso, pero imaginemos que quisiéramos evitar que el usuario local ``usu2`` pueda conectarse:  
        ```
        chroot_list_enable=YES
        chroot_list_file=/etc/vsftpd.chroot_list
        ```
        Y añdimos al usuario ``usu2`` al ``chroot_list``:
        ```
        echo 'usu2' | sudo tee -a /etc/vsftpd.chroot_list
        ```
    - Configuración FTPS Explicito sobre TLS  
        Habilitamos el soporte TLS/SSL:  
        ```
        ssl_enable=YES
        ```
        El usuario anónimo tampoco puede conectarse mediante conexiones cifradas:  
        ```
        allow_anon_ssl=NO
        ```
        Forzamos que la autenticación de los usuarios locales esté cifrada con TLS/SSL:
        ```
        force_local_logins_ssl=YES
        ```
        No sólo el usuario/contraseña es importante, sino la información también:
        ```
        force_local_data_ssl=YES
        ```
        Ciframos usando TLSv1, que es más seguro que SSLv2 y SSLv3:
        ```
        ssl_tlsv1=YES
        ssl_sslv2=NO
        ssl_sslv3=NO
        ```
        Dado que mediante [Let’s Encrypt](https://letsencrypt.org/) [obtuvimos](https://profesorjavi.github.io/curso_apache24/curso/u28/cert-Lets_encript.html) el certificado para nuestro sitio web, lo aprovechamos e indicamos la ruta del certificado y clave privada:  
        ```
        rsa_cert_file=/etc/letsencrypt/live/marchante.ddns.net/fullchain.pem
        rsa_private_key_file=/etc/letsencrypt/live/marchante.ddns.net/privkey.pem
        ```
        Evitar error ``vsftpd refusing to run with writable root inside chroot()``:  
        vsftpd incorpora un sistema de seguridad para que los usuarios enjaulados no puedan escribir en sus directorios; para solucionarlo habilitaremos la siguiente directiva:  
        ```
        allow_writeable_chroot=YES
        ```
vsftpd admite más configuraciones, pero con las citadas cumple con nuestras necesidades; quedaría así:  
```
# Cconfiguraciones generales
listen=NO
listen_ipv6=YES
anonymous_enable=NO
download_enable=YES
ftpd_banner=Welcome to FTP Marchante
connect_from_port_20=NO
dirmessage_enable=YES
use_localtime=YES

# Configuración modo pasivo
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
# Configuración usuarios locales
local_enable=YES
write_enable=YES
local_umask=022
chroot_local_user=YES
user_sub_token=$USER
local_root=/home/$USER/public_html

# Configuracin SSL/TLS
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
ssl_enable=YES
allow_anon_ssl=NO
force_local_logins_ssl=YES
force_local_data_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
allow_writeable_chroot=YES
rsa_cert_file=/etc/letsencrypt/live/marchante.ddns.net/fullchain.pem
rsa_private_key_file=/etc/letsencrypt/live/marchante.ddns.net/privkey.pem
```