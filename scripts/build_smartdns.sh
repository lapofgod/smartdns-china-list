#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_DIR="${1:-upstream}"
OUTPUT_DIR="${2:-dist}"
REPO_SLUG="${3:-OWNER/REPO}"

if [[ ! -d "$UPSTREAM_DIR" ]]; then
  echo "Upstream directory does not exist: $UPSTREAM_DIR" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

extract_domains() {
  local src_file="$1"
  awk '
    /^server=\// {
      line = $0
      sub(/^server=\//, "", line)
      split(line, parts, "/")
      domain = parts[1]
      if (domain != "") {
        print domain
      }
    }
  ' "$src_file"
}

write_smartdns_file() {
  local src_file="$1"
  local out_file="$2"

  extract_domains "$src_file" | sort -u > "$out_file"
}

combined_domains_file="$OUTPUT_DIR/smartdns-domains.china.conf"
all_domains_tmp="$OUTPUT_DIR/.all-domains.tmp"
: > "$all_domains_tmp"

generated_count=0
for src in "$UPSTREAM_DIR"/*.china.conf; do
  if [[ ! -f "$src" ]]; then
    continue
  fi

  base_name="$(basename "$src")"
  out_name="${base_name%.conf}.smartdns.conf"
  out_path="$OUTPUT_DIR/$out_name"

  write_smartdns_file "$src" "$out_path"
  extract_domains "$src" >> "$all_domains_tmp"
  generated_count=$((generated_count + 1))
done

if [[ "$generated_count" -eq 0 ]]; then
  echo "No .china.conf files found in $UPSTREAM_DIR" >&2
  exit 1
fi

sort -u "$all_domains_tmp" > "$combined_domains_file"

rm -f "$all_domains_tmp"

readme_file="$OUTPUT_DIR/README.MD"
{
  echo "# smartdns-china-list generated files"
  echo
  echo "These files are generated from:"
  echo
  echo "- https://github.com/felixonmars/dnsmasq-china-list"
  echo
  echo "Generated at (UTC): $(date -u +"%Y-%m-%d %H:%M:%S")"
  echo
  echo "## Access links"
  echo
  echo "| File | raw.githubusercontent.com | cdn.jsdelivr.net | fastly.jsdelivr.net | testingcf.jsdelivr.net | gh-proxy.org |"
  echo "|---|---|---|---|---|---|"

  find "$OUTPUT_DIR" -maxdepth 1 \( -type f -o -type l \) ! -name "README.MD" -printf "%f\n" | sort | while IFS= read -r file; do
    raw_url="https://raw.githubusercontent.com/${REPO_SLUG}/generated/${file}"
    jsdelivr_url="https://cdn.jsdelivr.net/gh/${REPO_SLUG}@generated/${file}"
    fastly_url="https://fastly.jsdelivr.net/gh/${REPO_SLUG}@generated/${file}"
    testingcf_url="https://testingcf.jsdelivr.net/gh/${REPO_SLUG}@generated/${file}"
    gh_proxy_url="https://gh-proxy.org/${raw_url}"

    echo "| ${file} | [link](${raw_url}) | [link](${jsdelivr_url}) | [link](${fastly_url}) | [link](${testingcf_url}) | [link](${gh_proxy_url}) |"
  done
} > "$readme_file"

echo "Generated ${generated_count} pure domain-list files + combined file into ${OUTPUT_DIR}"
