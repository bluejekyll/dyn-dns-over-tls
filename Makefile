TARGET_DIR = target
TDNS_BRANCH = trust-dns-client-cli

.PHONY: init-trust-dns
init-trust-dns:
	@cargo install trust-dns --bin named --git https://github.com/bluejekyll/trust-dns.git --branch ${TDNS_BRANCH}
	mv ~/.cargo/bin/named ~/.cargo/bin/tdns-named
	@tdns-named --version

.PHONY: init
init:
	@echo "====> Testing for all tools"
	@cargo ${RUSTV} --version || (echo rust is required, e.g. 'curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh' && cargo --version)
	@dns --version || cargo install trust-dns-util --bin dns --git https://github.com/bluejekyll/trust-dns.git --branch ${TDNS_BRANCH}
	@tdns-named --version || ${MAKE} init-trust-dns
