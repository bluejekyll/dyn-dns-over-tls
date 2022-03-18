# Example of Dynamic DNS over TLS/HTTPS/Quic?

This is an example of performing dynamic DNS with trust-dns.

## Design

This leverages a new CLI in trust-dns called `dns` which is a wrapper over the trust-dns-client library.

See this branch: https://github.com/bluejekyll/trust-dns/tree/trust-dns-client-cli

## Testing

Use the Makefile to initialize with `make init`. This will ask for rust tools to be installed, easiest path is to use https://rustup.rs/
