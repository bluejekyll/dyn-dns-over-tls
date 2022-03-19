TARGET_DIR = target
TDNS_BRANCH = trust-dns-client-cli

TEST_ZONE = doq.sinodun.com.
NS = ns4.xot.rocks
NS_IP = 18.198.201.187

.PHONY: init-trust-dns
init-trust-dns:
	@cargo install trust-dns --all-features --bin named --git https://github.com/bluejekyll/trust-dns.git --branch ${TDNS_BRANCH}
	mv ~/.cargo/bin/named ~/.cargo/bin/tdns-named
	@tdns-named --version

.PHONY: init
init:
	@echo "====> Testing for all tools"
	@cargo ${RUSTV} --version || (echo rust is required, e.g. 'curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh' && cargo --version)
	@dns --version || cargo install trust-dns-util --all-features --bin dns --git https://github.com/bluejekyll/trust-dns.git --branch ${TDNS_BRANCH}
	@tdns-named --version || ${MAKE} init-trust-dns

.PHONY: clean
clean:
	@echo "====> Cleaning"
	rm ~/.cargo/bin/tdns-named
	rm ~/.cargo/bin/dns

.PHONY: test-dns
test-dns:
	@echo "====> Test tcp dns setup"
	dns -p tcp -n 8.8.8.8:53 query www.salesforce.com A
	@echo "====> Test tls dns setup"
	dns -p tls -n 8.8.8.8:853 -t dns.google query www.salesforce.com AAAA
	@echo "====> Test tls dns setup"
	dns -p https -n 8.8.8.8:443 -t dns.google query www.salesforce.com AAAA

.PHONY: test-tcp
test-tcp:
	@echo "====> Testing TCP connection to ${TEST_ZONE} and updates"
	dns -p tcp -n ${NS_IP}:53 query ${TEST_ZONE} SOA
	dns -p tcp -n ${NS_IP}:53 -z ${TEST_ZONE} create tdns.${TEST_ZONE} TXT 60 HELLO_WORLD
	dns -p tcp -n ${NS_IP}:53 query tdns.${TEST_ZONE} TXT
	dns -p tcp -n ${NS_IP}:53 -z ${TEST_ZONE} delete-record tdns.${TEST_ZONE} TXT HELLO_WORLD
	dns -p tcp -n ${NS_IP}:53 query tdns.${TEST_ZONE} TXT

.PHONY: test-tls
test-tls:
	@echo "====> Testing TLS connection to ${TEST_ZONE} and updates"
	dns -p tls -n ${NS_IP}:853 -t sinodun.com query ${TEST_ZONE} SOA
	dns -p tls -n ${NS_IP}:853 -t sinodun.com -z ${TEST_ZONE} create tdns.${TEST_ZONE} TXT 60 HELLO_WORLD
	dns -p tls -n ${NS_IP}:853 -t sinodun.com query tdns.${TEST_ZONE} TXT
	dns -p tls -n ${NS_IP}:853 -t sinodun.com -z ${TEST_ZONE} delete-record tdns.${TEST_ZONE} TXT HELLO_WORLD
	dns -p tls -n ${NS_IP}:853 -t sinodun.com query tdns.${TEST_ZONE} TXT