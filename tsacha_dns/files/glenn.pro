$TTL 180
glenn.pro.           IN SOA    glenn.pro. sacha.tremoureux.fr. (
                         2014070704 ; serial
                         86400      ; refresh (1 day)
                         3600       ; retry (1 hour)
                         3600000    ; expire (5 weeks 6 days 16 hours)
                         300        ; minimum (5 minutes)
                     )

                     NS                     dns.duna.trs.io.
                     NS                     dns.jool.trs.io.

                     A                      5.39.90.146
                     AAAA                   2001:41d0:8:9c92::1


                     IN TXT                 "v=spf1 ip4:188.165.204.102 ip6:2001:41d0:2:9566:1::4 -all"
                     MX             1       mail.s.tremoureux.fr.

www                  CNAME                  www.s.tremoureux.fr.
autoconfig           CNAME                  www.s.tremoureux.fr.

im                   CNAME                  im.s.tremoureux.fr.


_jabber._tcp         SRV     5 0 5269       im.s.tremoureux.fr.
_xmpp-client._tcp    SRV     5 0 5222       im.s.tremoureux.fr.
_xmpp-server._tcp    SRV     5 0 5269       im.s.tremoureux.fr.
