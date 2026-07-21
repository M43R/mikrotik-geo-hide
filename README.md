# geo-hide

Synchronize a MikroTik FQDN Address List from a domain list stored in GitHub.

The script downloads `domains.txt` from a GitHub repository, parses the file, removes comments and empty lines, and populates a RouterOS Address List. The built-in FQDN support automatically resolves and maintains the corresponding IP addresses.

## Features

- Download domain list from GitHub
- Supports private repositories (GitHub Personal Access Token)
- Supports inline comments (`#`)
- Ignores empty lines
- Prevents duplicate Address List entries
- Imports only valid non-empty records
- Simple logging with import statistics
- No external dependencies
- No container or external service required

## Repository Structure

```text
geo-hide/
├── domain-sync.rsc
├── domains.txt
└── README.md
```

## domains.txt example

```text
# AI

chatgpt.com
claude.ai
grok.com

# Hardware

intel.com
intel.de
intel.se

# Productivity

jetbrains.com
```

Inline comments are also supported:

```text
intel.com      # Intel
chatgpt.com    # OpenAI
```

## Example log

```text
geo-hide: Downloading domains.txt...
geo-hide: Flushing old entries...
geo-hide: Parsing domains.txt...
geo-hide: Update completed. Imported=301
```

If duplicate or invalid entries are detected:

```text
geo-hide: Ignored 'intel.com'
```

## Requirements

- RouterOS 7.0+
- HTTPS access from the router

## How it works

1. Download `domains.txt` from GitHub.
2. Parse the file.
3. Clear existing static entries from the target Address List.
4. Import new FQDN entries.
5. RouterOS automatically resolves and maintains all associated IP addresses.

## Why use FQDN Address Lists?

RouterOS automatically:

- resolves A records;
- tracks DNS changes;
- updates IP addresses according to DNS TTL;
- supports multiple IP addresses per hostname.

No custom DNS resolver or scheduled resolve script is required.

## TODO

### Reliability

- [ ] Compare downloaded file checksum before import
- [ ] Keep local cache of the previous `domains.txt`
- [ ] Rollback on failed import

### Validation

- [ ] Domain name validation
- [ ] IPv6 (AAAA) support
- [ ] Wildcard behavior testing

### Performance

- [ ] Skip Address List rebuild if file has not changed
- [ ] Benchmark large domain lists (500–1000 domains)

### Documentation

- [ ] Add installation guide
- [ ] Add troubleshooting section

## License
