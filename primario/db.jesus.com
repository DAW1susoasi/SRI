$TTL    1d ; default expiration time (in seconds) of all RRs without their own TTL value
@       IN      SOA     ns1.jesus.com. admin.jesus.com. (
                  2023100501	; Serial
                  1d		; Refresh
                  1h		; Retry
                  1w     	; Expire
                  1h )   	; Negative Cache TTL

; name servers - NS records
@     	IN      NS      ns1.jesus.com.
@     	IN      NS      ns2.jesus.com.

; Mail server - MX records
@       IN      MX	10 45.67.34.2 ; Prioridad 10 para el servidor de correo

$ORIGIN jesus.com.
; name servers - A records
@     	IN      A	192.168.100.2
ns1	IN      A	192.168.100.2
ns2	IN      A	192.168.100.3
www	IN      A	56.23.45.3
ftp	IN      A	56.23.45.3
;www	IN      CNAME	ns1
;ftp	IN      CNAME	ns1

$ORIGIN valencia.jesus.com.
www     IN      A      56.23.45.3
ftp     IN      A      56.23.45.3
;@	IN	NS	ns.valencia.jesus.com.
;ns	IN	A	192.168.100.4

$ORIGIN caceres.jesus.com.
www     IN      A      56.23.45.3
ftp     IN      A      73.56.12.2
;@	IN	NS	ns.caceres.jesus.com.
;ns	IN	A	192.168.100.5
