$ORIGIN	caceres.jesus.com.
$TTL    1d ; default expiration time (in seconds) of all RRs without their own TTL value
@       IN      SOA     ns.caceres.jesus.com. admin.caceres.jesus.com. (
                  2023100501	; Serial
                  1d		; Refresh
                  1h		; Retry
                  1w     	; Expire
                  1h )   	; Negative Cache TTL

; name servers - NS records
@     	IN      NS      ns.caceres.jesus.com.

; name servers - A records
@	IN	A	192.168.100.5
ns	IN      A	192.168.100.5
www	IN      A	56.23.45.3
ftp	IN      A	56.23.45.3
;www	IN      CNAME	ns
;ftp	IN      CNAME	ns



