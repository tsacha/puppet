$TTL 180
trs.io.                        IN SOA    trs.io. sacha.tremoureux.fr. (
                                   2014072701     ; serial
                                   86400      ; refresh (1 day)
                                   3600       ; retry (1 hour)
                                   3600000    ; expire (5 weeks 6 days 16 hours)
                                   300        ; minimum (5 minutes)
                               )
		               
                               NS                     dns.duna.trs.io.
                               NS                     dns.jool.trs.io.
		               
                               A                      188.165.204.102
                               AAAA                   2001:41d0:2:9566:1::3
		               
; BERGEN	               
b                              CNAME                  bergen.s.tremoureux.fr.
		               
; TRONDHEIM (HOME)             
h                              CNAME                  trondheim.s.tremoureux.fr.
		               
; TROMSØ	               
t                              CNAME                  tromso.s.tremoureux.fr.
		               
; Apps		               
m                              CNAME                  webmail.s.tremoureux.fr.
dr                             CNAME                  web.s.tremoureux.fr.
		               
; KERBIN	               
kerbin                         A                      5.39.90.146
kerbin                         AAAA                   2001:41d0:8:9c92::1
		               
; DUNA		               
duna                           A                      188.165.204.102
duna                           AAAA                   2001:41d0:2:9566::
		               
dns.duna                       A                      188.165.204.102
dns.duna                       AAAA                   2001:41d0:2:9566:1::2
		               
ldap.duna                      A                      188.165.204.102
ldap.duna                      AAAA                   2001:41d0:2:9566:1::3
		               
mail.duna                      A                      188.165.204.102
mail.duna                      AAAA                   2001:41d0:2:9566:1::4
		               
psql.duna                      A                      188.165.204.102
psql.duna                      AAAA                   2001:41d0:2:9566:1::5

im.duna                        A                      188.165.204.102
im.duna                        AAAA                   2001:41d0:2:9566:1::6

web.duna                       A                      188.165.204.102
web.duna                       AAAA                   2001:41d0:2:9566:1::7
		               
vpn.duna                       A                      188.165.204.102
vpn.duna                       AAAA                   2001:41d0:2:9566:1::8
		               
mumble.duna                    A                      188.165.204.102
mumble.duna                    AAAA                   2001:41d0:2:9566:1::9

mariadb.duna                   A                      188.165.204.102
mariadb.duna                   AAAA                   2001:41d0:2:9566:1::10
		               
glenn.duna                     A                      188.165.204.102
glenn.duna                     AAAA                   2001:41d0:2:9566:1::101
		               
tc.duna                        A                      188.165.204.102
tc.duna                        AAAA                   2001:41d0:2:9566:1::102
		               
sacha.duna                     A                      188.165.204.102
sacha.duna                     AAAA                   2001:41d0:2:9566:1::103
		               
; JOOL		               
jool                           A                      188.165.216.190
jool                           AAAA                   2001:41d0:2:a3be::
		               
dns.jool                       A                      188.165.216.190
dns.jool                       AAAA                   2001:41d0:2:a3be:1::2
		               
ldap.jool                      A                      188.165.216.190
ldap.jool                      AAAA                   2001:41d0:2:a3be:1::3
		               
mail.jool                      A                      188.165.216.190
mail.jool                      AAAA                   2001:41d0:2:a3be:1::4
		               
psql.jool                      A                      188.165.216.190
psql.jool                      AAAA                   2001:41d0:2:a3be:1::5
		               
im.jool                        A                      188.165.216.190
im.jool                        AAAA                   2001:41d0:2:a3be:1::6

web.jool                       A                      188.165.216.190
web.jool                       AAAA                   2001:41d0:2:a3be:1::7
		               
vpn.jool                       A                      188.165.216.190
vpn.jool                       AAAA                   2001:41d0:2:a3be:1::8
		               
mumble.jool                    A                      188.165.216.190
mumble.jool                    AAAA                   2001:41d0:2:a3be:1::9
		               
glenn.jool                     A                      188.165.216.190
glenn.jool                     AAAA                   2001:41d0:2:a3be:1::101
		               
tc.jool                        A                      188.165.216.190
tc.jool                        AAAA                   2001:41d0:2:a3be:1::102
		               
sacha.jool                     A                      188.165.216.190
sacha.jool                     AAAA                   2001:41d0:2:a3be:1::103

canopsis.jool                  A                      188.165.216.190
canopsis.jool                  AAAA                   2001:41d0:2:a3be:1::201


; FRONT DNS
dns                            CNAME                  dns.duna
mail                           CNAME                  mail.duna
www                            CNAME                  web.duna
webmail                        CNAME                  web.duna
psql                           CNAME                  psql.duna
ldap                           CNAME                  ldap.duna
im                             CNAME                  im.duna
vpn                            CNAME                  vpn.duna
mumble                         CNAME                  mumble.duna
canopsis                       CNAME                  canopsis.jool
