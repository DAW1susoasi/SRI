# HTTPS con Let’s Encrypt y Certbot
***
- ¿Qué es [Let’s Encrypt](https://letsencrypt.org/)?  
Es una autoridad de certificación que proporciona [certificados X.509](https://es.wikipedia.org/wiki/X.509) gratuitos para el cifrado de seguridad de nivel de transporte (TLS) a través de un proceso automatizado diseñado para eliminar el complejo proceso actual de creación manual, la validación, firma, instalación y renovación de los certificados de sitios web seguros.  
- ¿Qué es [Certbot](https://certbot.eff.org/)?  
Es el cliente del [protocolo ACME](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment) encargado de demostrar que se tiene control sobre el dominio del que queremos obtener un certificado de Let’s Encrypt.  
Instalación y configuración de Certbot en una máquina con el **servidor web Apache** y el **sistema operativo Ubuntu 22.04**.  
1. Configuración de HTTPS  
    - Activar el módulo SSL:  
        ```
        a2enmod ssl
        ```
    - Crear un virtual host para nuestro FQDN a partir del fichero por defecto para la configuración de HTTPS:  
        ```
        cp default-ssl.conf marchante-ssl.conf
        ```
    - Editamos el archivo marchante-ssl.conf conforme a nuestras necesidades:  
        ```
        <IfModule mod_ssl.c>
        <VirtualHost *:443>  
            ServerAdmin webmaster@marchante.ddns.net  
            DocumentRoot /var/www/marchante  
            ServerName marchante.ddns.net  
            ErrorLog ${APACHE_LOG_DIR}/error.log  
            CustomLog ${APACHE_LOG_DIR}/access.log combined  
            <Directory "/var/www/marchante/admin">
                    AuthUserFile "/etc/apache2/digest.txt"
                    AuthName "admin"
                    AuthType Digest
                    Require valid-user
            </Directory>
        </VirtualHost>
        </IfModule>
        ```
    - Activamos el sitio::  
        ```
        a2ensite marchante-ssl.conf
        ```
2. Certificado para nuestro sitio web  
    - Instalación de snapd:  
        ```
        sudo apt update && apt install snapd
        ```
    - Instación de Certbot mediante snapd:  
        ```
        sudo snap install –classic certbot  
        ```
    - Creamos una alias para el comando certbot:  
        ```bash
        sudo ln -fs /snap/bin/certbot /usr/bin/certbot
        ```
    - Obtenemos el certificado y configuramos el servidor web Apache (Certbot editará automáticamente la configuración de Apache para servirlo, activando el acceso HTTPS y redirigiendo HTTP a HTTPS **en un solo paso**; si queremos editar el archivo .conf de Apache a mano (**no es el caso**), ejecutamos ```$ sudo certbot certonly --apache```):  
        ```
        sudo certbot --apache
        ```  
        Durante la ejecución del comando anterior tendremos que contestar algunas preguntas: dirección de correo electrónico, aceptar los términos de uso, etc, y lo más importante, **nos preguntará el nombre del dominio**, si no lo encuentra en los archivos de configuración del servidor web.  

        Certbot renovará el certificado automáticamente antes de que expire (no tendremos que ejecutar Certbot de nuevo, a menos que cambiemos la configuración); podemos probar la renovación automática del certificado ejecutando este comando: ``` sudo certbot renew --dry-run ```  
    - Archivo marchante-ssl.conf tras ser editado por Certbot:  
        ```
        <IfModule mod_ssl.c>
        <VirtualHost *:443>  
            ServerAdmin webmaster@marchante.ddns.net  
            DocumentRoot /var/www/marchante  
            ServerName marchante.ddns.net  
            ErrorLog ${APACHE_LOG_DIR}/error.log  
            CustomLog ${APACHE_LOG_DIR}/access.log combined  
            <Directory "/var/www/marchante/admin">
                    AuthUserFile "/etc/apache2/digest.txt"
                    AuthName "admin"
                    AuthType Digest
                    Require valid-user
            </Directory>
        SSLCertificateFile /etc/letsencrypt/live/marchante.ddns.net/fullchain.pem  
        SSLCertificateKeyFile /etc/letsencrypt/live/marchante.ddnsnet/privkey.pem  
        Include /etc/letsencrypt/options-ssl-apache.conf  
        </VirtualHost>
        </IfModule>
        ```

