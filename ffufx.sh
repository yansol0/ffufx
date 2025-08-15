#!/usr/bin/env bash
set -euo pipefail

url=""
args=()
while (( "$#" )); do
  case "$1" in
    -u|--url)
      url="$2"
      args+=("$1" "$2")
      shift 2
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

if [ -z "${url}" ]; then
  cat <<EOF
Usage: $(basename "$0") -u <URL> [ffuf options]

Description:
  A wrapper around ffuf that:
    • Runs ffuf with your provided arguments
    • Extracts the full URL and status code from results
    • Appends them to a domain-named file in the current directory
    • Creates the file if it does not exist
    • Cleans up temporary JSON output

Arguments:
  -u, --url   Target URL for ffuf (must contain FUZZ keyword)
  [options]   Any other ffuf options (wordlist, matchers, filters, etc.)

Example:
  ffufx -u https://test.example.com/FUZZ -w paths.txt -mc all

Output:
  If the target URL is https://test.example.com/FUZZ,
  results will be stored in a file named:
    ffufx_test.example.com

EOF
  exit 1
fi

domain=$(printf '%s' "$url" | awk -F/ '{print $3}')
outfile="ffufx_$domain"
[ -f "$outfile" ] || : > "$outfile"

tmp=""
newtmp=""
trap 'rm -f "$tmp" "$newtmp"' EXIT

tmp="$(mktemp ".ffuf_${domain}_XXXXXX.json")"
newtmp="$(mktemp ".ffuf_${domain}_XXXXXX.txt")"

ffuf "${args[@]}" -of json -o "$tmp" >/dev/null
jq -r '.results[] | "\(.url) [\(.status)]"' "$tmp" > "$newtmp"

if [ -s "$outfile" ]; then
  awk 'NR==FNR{seen[$0]=1; next} !seen[$0]' "$outfile" "$newtmp" >> "$outfile"
else
  cat "$newtmp" >> "$outfile"
fi

