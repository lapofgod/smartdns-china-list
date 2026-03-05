# smartdns-china-list

Automatically syncs domain rules from upstream `dnsmasq-china-list`, converts them to pure domain-list format (one domain per line), and publishes generated files to the `generated` branch.

## Upstream

- https://github.com/felixonmars/dnsmasq-china-list

## What This Repository Does

1. GitHub Actions periodically clones upstream rules.
2. Converts `*.china.conf` files to pure domain-list files (one domain per line).
3. Publishes generated artifacts to the `generated` branch root.
4. Regenerates `generated/README.MD` with external access links for each file.

## Workflow

- File: `.github/workflows/sync-build.yml`
- Triggers:
  - Manual: `workflow_dispatch`
  - Scheduled: daily (`cron: 15 2 * * *`, UTC)

## Generated Files

Generated artifacts are available in branch `generated`.

Common files include:


- `accelerated-domains.china.smartdns.conf`
- `apple.china.smartdns.conf`
- `google.china.smartdns.conf`
- `bogus-nxdomain.china.smartdns.conf`
- `smartdns-domains.china.conf`
- `README.MD` (contains per-file external links)

## SmartDNS Usage Example

```conf
# Pure domain list file (one domain per line)
# /path/to/smartdns-domains.china.conf

# Import with your preferred SmartDNS domain-set workflow.
# Exact directives can vary by SmartDNS version.
```

## External Link Providers (in generated/README.MD)

- `raw.githubusercontent.com`
- `cdn.jsdelivr.net`
- `fastly.jsdelivr.net`
- `testingcf.jsdelivr.net`
- `gh-proxy.org`

## Notes

- The generated links in `generated/README.MD` are built using `${{ github.repository }}` at workflow runtime.
- If you fork this repository, links automatically point to your fork after Actions run.
