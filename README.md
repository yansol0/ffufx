# ffufx

A convenience wrapper around `ffuf` and `jq` that automatically captures and organizes fuzzing results.

## What it does

ffufx runs `ffuf` with your provided arguments and automatically:
- Extracts full URLs and status codes from the results
- Saves them to a domain-named file in the current directory
- Dedupes results across multiple runs
- Cleans up temporary files

## Requirements

- `ffuf` - Fast web fuzzer
- `jq` - JSON processor

## Usage

```bash
ffufx -u <URL> [ffuf options]
```

### Arguments

- `-u, --url`: Target URL for ffuf (must contain `FUZZ` keyword)
- `[options]`: Any other ffuf options (wordlist, matchers, filters, etc.)

### Examples

```bash
# Basic directory fuzzing
ffufx -u https://example.com/FUZZ -w wordlist.txt

# Fuzz with custom matchers and filters
ffufx -u https://test.example.com/FUZZ -w paths.txt -mc 200,301,302 -fs 1234

## Output

Results are automatically saved to a file named `ffufx_<domain>` in the current directory.

For example, if fuzzing `https://test.example.com/FUZZ`, results will be stored in:
```
ffufx_test.example.com
```

Each line contains:
```
https://test.example.com/admin [200]
https://test.example.com/login [302]
```
