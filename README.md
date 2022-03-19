# Example of Dynamic DNS over TLS/HTTPS/Quic?

This is an example of performing dynamic DNS with trust-dns.

## Design

This leverages a new CLI in trust-dns called `dns` which is a wrapper over the trust-dns-client library.

See this branch: https://github.com/bluejekyll/trust-dns/tree/trust-dns-client-cli

## Initialization (this will probably only work on a unix-like env right now)

Use the Makefile to initialize with `make init`. This will ask for rust tools to be installed, easiest path is to use https://rustup.rs/

## Testing

The tests perform these operations:
- First this queries for the `doq.sinodun.com.` from the nameserver at `18.198.201.187`
- These tests will create a new `TXT` record in the `doq.sinodun.com.` zone with the label `tdns.doq.sinodun.com.` with the value `HELLO_WORLD`
- Next it queries for the `TXT` record to show it's existance
- Then it deletes the `TXT` record
- Finally it queries for the `TXT` record to ensure an `NXDOMAIN` response

### TCP (verify the server is accepting dynamic DNS updates)

```shell
$ make test-tcp
====> Testing TCP connection to doq.sinodun.com. and updates
dns -p tcp -n 18.198.201.187:53 query doq.sinodun.com. SOA
; using tcp:18.198.201.187:53
; sending query: doq.sinodun.com. IN SOA
; received response
; header 32170:RD,AA,RA:NoError:QUERY:1/0/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: doq.sinodun.com. type: SOA class: IN
; answers 1
doq.sinodun.com. 300 IN SOA ns4.xot.rocks. jad.sinodun.com. 2016121638 30000 300 604800 300
; nameservers 0
; additionals 1

dns -p tcp -n 18.198.201.187:53 -z doq.sinodun.com. create tdns.doq.sinodun.com. TXT 60 HELLO_WORLD
; using tcp:18.198.201.187:53
; sending create: tdns.doq.sinodun.com. IN TXT in doq.sinodun.com.
; received response
; header 54817::NoError:UPDATE:0/0/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: doq.sinodun.com. type: SOA class: IN
; answers 0
; nameservers 0
; additionals 1

dns -p tcp -n 18.198.201.187:53 query tdns.doq.sinodun.com. TXT
; using tcp:18.198.201.187:53
; sending query: tdns.doq.sinodun.com. IN TXT
; received response
; header 10433:RD,AA,RA:NoError:QUERY:1/0/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: tdns.doq.sinodun.com. type: TXT class: IN
; answers 1
tdns.doq.sinodun.com. 60 IN TXT HELLO_WORLD
; nameservers 0
; additionals 1

dns -p tcp -n 18.198.201.187:53 -z doq.sinodun.com. delete-record tdns.doq.sinodun.com. TXT HELLO_WORLD
; using tcp:18.198.201.187:53
; sending delete-record: tdns.doq.sinodun.com. IN TXT from doq.sinodun.com.
; received response
; header 62380::NoError:UPDATE:0/0/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: doq.sinodun.com. type: SOA class: IN
; answers 0
; nameservers 0
; additionals 1

dns -p tcp -n 18.198.201.187:53 query tdns.doq.sinodun.com. TXT
; using tcp:18.198.201.187:53
; sending query: tdns.doq.sinodun.com. IN TXT
; received response
; header 11035:RD,AA,RA:NXDomain:QUERY:0/1/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: tdns.doq.sinodun.com. type: TXT class: IN
; answers 0
; nameservers 1
doq.sinodun.com. 300 IN SOA ns4.xot.rocks. jad.sinodun.com. 2016121640 30000 300 604800 300
; additionals 1
```

### TLS (this is based on a custom dns client that has disabled tls cert validation)

```shell
$ make test-tls
====> Testing connection to doq.sinodun.com. and updates
dns -p tls -n 18.198.201.187:853 -t sinodun.com query doq.sinodun.com. SOA
; using tls:18.198.201.187:853 dns_name:sinodun.com
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
; sending query: doq.sinodun.com. IN SOA
; received response
; header 997:RD,AA,RA:NoError:QUERY:1/0/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: doq.sinodun.com. type: SOA class: IN
; answers 1
doq.sinodun.com. 300 IN SOA ns4.xot.rocks. jad.sinodun.com. 2016121636 30000 300 604800 300
; nameservers 0
; additionals 1

dns -p tls -n 18.198.201.187:853 -t sinodun.com -z doq.sinodun.com. create tdns.doq.sinodun.com. TXT 60 HELLO_WORLD
; using tls:18.198.201.187:853 dns_name:sinodun.com
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
; sending create: tdns.doq.sinodun.com. IN TXT in doq.sinodun.com.
; received response
; header 33257::NoError:UPDATE:0/0/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: doq.sinodun.com. type: SOA class: IN
; answers 0
; nameservers 0
; additionals 1

dns -p tls -n 18.198.201.187:853 -t sinodun.com query tdns.doq.sinodun.com. TXT
; using tls:18.198.201.187:853 dns_name:sinodun.com
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
; sending query: tdns.doq.sinodun.com. IN TXT
; received response
; header 63736:RD,AA,RA:NoError:QUERY:1/0/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: tdns.doq.sinodun.com. type: TXT class: IN
; answers 1
tdns.doq.sinodun.com. 60 IN TXT HELLO_WORLD
; nameservers 0
; additionals 1

dns -p tls -n 18.198.201.187:853 -t sinodun.com -z doq.sinodun.com. delete-record tdns.doq.sinodun.com. TXT HELLO_WORLD
; using tls:18.198.201.187:853 dns_name:sinodun.com
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
; sending delete-record: tdns.doq.sinodun.com. IN TXT from doq.sinodun.com.
; received response
; header 6541::NoError:UPDATE:0/0/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: doq.sinodun.com. type: SOA class: IN
; answers 0
; nameservers 0
; additionals 1

dns -p tls -n 18.198.201.187:853 -t sinodun.com query tdns.doq.sinodun.com. TXT
; using tls:18.198.201.187:853 dns_name:sinodun.com
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
;!!!THIS IS NOT VERIFYING THE SERVER TLS CERTIFICATE!!!
; sending query: tdns.doq.sinodun.com. IN TXT
; received response
; header 58718:RD,AA,RA:NXDomain:QUERY:0/1/1
; edns version: 0 dnssec_ok: false max_payload: 1232 opts: 0
; query
;; name: tdns.doq.sinodun.com. type: TXT class: IN
; answers 0
; nameservers 1
doq.sinodun.com. 300 IN SOA ns4.xot.rocks. jad.sinodun.com. 2016121638 30000 300 604800 300
; additionals 1
```