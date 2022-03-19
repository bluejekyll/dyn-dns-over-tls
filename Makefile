TARGET_DIR = target
TDNS_BRANCH = trust-dns-client-cli

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
