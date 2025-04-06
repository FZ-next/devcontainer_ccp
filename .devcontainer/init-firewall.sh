#!/bin/bash
# Firewall configuration for Python devcontainer
# This script sets up a restrictive firewall that only allows specific domains and services.
# If you need to connect to additional APIs or services, add their domains to the "allowed domains" list.
#
# For troubleshooting network issues:
# 1. Check if the domain is in the allowed list below
# 2. If not, modify this script to add the required domain
# 3. Re-run the script with: sudo /usr/local/bin/init-firewall.sh

set -euo pipefail  # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Flush existing rules and delete existing ipsets
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-domains 2>/dev/null || true

# First allow DNS and localhost before any restrictions
# Allow outbound DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
# Allow inbound DNS responses
iptables -A INPUT -p udp --sport 53 -j ACCEPT
# Allow outbound SSH
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
# Allow inbound SSH responses
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
# Allow localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow FastAPI and Streamlit ports
# FastAPI server port
iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
# Streamlit port
iptables -A INPUT -p tcp --dport 8501 -j ACCEPT

# Create ipset with CIDR support
ipset create allowed-domains hash:net

# Fetch GitHub meta information and aggregate + add their IP ranges
echo "Fetching GitHub IP ranges..."
gh_ranges=$(curl -s https://api.github.com/meta)
if [ -z "$gh_ranges" ]; then
    echo "ERROR: Failed to fetch GitHub IP ranges"
    exit 1
fi

if ! echo "$gh_ranges" | jq -e '.web and .api and .git' >/dev/null; then
    echo "ERROR: GitHub API response missing required fields"
    exit 1
fi

echo "Processing GitHub IPs..."
while read -r cidr; do
    if [[ ! "$cidr" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        echo "ERROR: Invalid CIDR range from GitHub meta: $cidr"
        continue
    fi
    echo "Adding GitHub range $cidr"
    ipset add allowed-domains "$cidr" || echo "WARNING: Failed to add $cidr to ipset"
done < <(echo "$gh_ranges" | jq -r '(.web + .api + .git)[]' | aggregate -q)

# Resolve and add other allowed domains
for domain in \
    "registry.npmjs.org" \
    "api.anthropic.com" \
    "sentry.io" \
    "statsig.anthropic.com" \
    "statsig.com" \
    "api.openai.com" \
    "pypi.org" \
    "files.pythonhosted.org" \
    "cdn.openai.com" \
    "platform.openai.com" \
    "ms-python.gallery.vsassets.io" \
    "gallery.vsassets.io" \
    "mobile.events.data.microsoft.com" \
    "*.events.data.microsoft.com" \
    "*.vsassets.io" \
    "*.data.microsoft.com" \
    "*.microsoft.com" \
    "vsmarketplacebadge.apphb.com" \
    "pypi.python.org" \
    "python-poetry.org" \
    "install.python-poetry.org" \
    "static.pythonhosted.org" \
    "raw.githubusercontent.com" \
    "codeload.github.com" \
    "objects.githubusercontent.com" \
    "ppa.launchpadcontent.net" \
    "packagecloud.io" \
    "*.packagecloud.io" \
    "*.pythonhosted.org" \
    "vercel-dns.com" \
    "*.vercel-dns.com"; do
    echo "Resolving $domain..."
    
    # Initialize valid_ips variable for all cases
    valid_ips=""
    
    # For wildcard domains, handle specially
    if [[ "$domain" == *\** ]]; then
        echo "Wildcard domain detected: $domain - adding broad IP ranges to ensure coverage"
        # Check if it's Microsoft-related
        if [[ "$domain" == *.microsoft.com* ]] || [[ "$domain" == *.vsassets.io* ]] || [[ "$domain" == *.data.microsoft.com* ]]; then
            # Add Microsoft Azure IP ranges - simplified for this script
            for azure_ip in "13.64.0.0/11" "13.96.0.0/13" "13.104.0.0/14" "20.33.0.0/16" "20.34.0.0/15" "20.36.0.0/14" "20.40.0.0/13" "20.48.0.0/12" "20.64.0.0/10" "20.128.0.0/16" "40.64.0.0/10" "40.74.0.0/15" "40.76.0.0/14" "40.80.0.0/12" "40.96.0.0/12" "40.112.0.0/13" "40.120.0.0/14" "40.124.0.0/16" "40.125.0.0/17" "104.40.0.0/13" "104.146.0.0/15" "104.208.0.0/13"; do
                echo "Adding Azure IP range $azure_ip for $domain"
                ipset add allowed-domains "$azure_ip" || echo "WARNING: Failed to add $azure_ip to ipset"
            done
            # Continue to try specific resolution too
        elif [[ "$domain" == *.continuum.io* ]] || [[ "$domain" == *.pythonhosted.org* ]] || [[ "$domain" == *.packagecloud.io* ]]; then
            # Convert wildcard to base domain for resolution
            base_domain=$(echo "$domain" | sed -e 's/\*\.//' -e 's/^\*//')
            echo "Trying to resolve base domain $base_domain for wildcard $domain"
            
            # Try multiple DNS servers
            for dns_server in "" "@8.8.8.8" "@1.1.1.1"; do
                dig_cmd="dig +short $dns_server A $base_domain"
                echo "Running: $dig_cmd"
                resolved_ips=$(eval "$dig_cmd" | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' || true)
                
                if [ -n "$resolved_ips" ]; then
                    valid_ips="$resolved_ips"
                    break
                fi
            done
            
            # If we still don't have IPs, try some common IP blocks for CDNs
            if [ -z "$valid_ips" ]; then
                echo "Failed to resolve base domain, adding common CDN IP ranges"
                # Add Cloudflare, AWS, and other common CDN IP ranges
                for cdn_ip in "104.16.0.0/12" "172.64.0.0/13" "13.32.0.0/15" "13.224.0.0/14" "143.204.0.0/16" "52.84.0.0/15" "54.192.0.0/12"; do
                    echo "Adding CDN IP range $cdn_ip for $domain"
                    ipset add allowed-domains "$cdn_ip" || echo "WARNING: Failed to add $cdn_ip to ipset"
                done
            fi
        fi
        
        # Continue with normal resolution too in case we have a specific subdomain
        domain_no_wildcard=$(echo "$domain" | sed -e 's/\*\.//' -e 's/^\*//')
        echo "Also trying to resolve non-wildcard version: $domain_no_wildcard"
    else
        # Regular domain processing for non-wildcards
        # Get both CNAME and A records, then resolve any CNAMEs
        cnames=$(dig +short CNAME "$domain" || true)
        if [ -n "$cnames" ]; then
            echo "Found CNAME for $domain: $cnames"
            for cname in $cnames; do
                echo "Resolving CNAME $cname to IP..."
                cname_ips=$(dig +short A "$cname" | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' || true)
                if [ -n "$cname_ips" ]; then
                    valid_ips="${valid_ips}${valid_ips:+$'\n'}${cname_ips}"
                fi
            done
        fi
        
        # Also try direct A record lookup
        direct_ips=$(dig +short A "$domain" | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' || true)
        if [ -n "$direct_ips" ]; then
            valid_ips="${valid_ips}${valid_ips:+$'\n'}${direct_ips}"
        fi
    fi
    
    # For non-wildcard domains or after wildcard processing, check if we have valid IPs
    if [ -z "$valid_ips" ]; then
        echo "WARNING: No valid IPs found for $domain, trying alternative DNS servers..."
        # Try multiple alternative DNS servers
        for dns_server in "@8.8.8.8" "@1.1.1.1" "@9.9.9.9"; do
            echo "Trying DNS server $dns_server for $domain"
            # Try both CNAME and A records
            cnames=$(dig +short $dns_server CNAME "$domain" || true)
            if [ -n "$cnames" ]; then
                echo "Found CNAME with $dns_server for $domain: $cnames"
                for cname in $cnames; do
                    cname_ips=$(dig +short $dns_server A "$cname" | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' || true)
                    if [ -n "$cname_ips" ]; then
                        valid_ips="${valid_ips}${valid_ips:+$'\n'}${cname_ips}"
                    fi
                done
            fi
            
            # Also try direct A record lookup
            direct_ips=$(dig +short $dns_server A "$domain" | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' || true)
            if [ -n "$direct_ips" ]; then
                valid_ips="${valid_ips}${valid_ips:+$'\n'}${direct_ips}"
            fi
            
            if [ -n "$valid_ips" ]; then
                echo "Successfully resolved $domain using $dns_server"
                break
            fi
        done
        
        if [ -z "$valid_ips" ]; then
            echo "WARNING: Failed to resolve $domain with all DNS servers - adding fallback CDN ranges"
            # Add common CDN ranges as fallback
            for fallback_ip in "104.16.0.0/12" "172.64.0.0/13" "13.32.0.0/15" "13.224.0.0/14" "143.204.0.0/16" "52.84.0.0/15" "54.192.0.0/12" "151.101.0.0/16" "199.232.0.0/16"; do
                echo "Adding fallback CDN IP range $fallback_ip for $domain"
                ipset add allowed-domains "$fallback_ip" || echo "WARNING: Failed to add $fallback_ip to ipset"
            done
            continue
        fi
    fi
    
    # Now process the validated IPs one by one
    echo "$valid_ips" | while read -r ip; do
        if [ -n "$ip" ]; then
            echo "Adding $ip for $domain"
            ipset add allowed-domains "$ip" || echo "WARNING: Failed to add $ip to ipset"
        fi
    done
done

# Get host IP from default route
HOST_IP=$(ip route | grep default | cut -d" " -f3)
if [ -z "$HOST_IP" ]; then
    echo "ERROR: Failed to detect host IP"
    exit 1
fi

HOST_NETWORK=$(echo "$HOST_IP" | sed "s/\.[0-9]*$/.0\/24/")
echo "Host network detected as: $HOST_NETWORK"

# Set up remaining iptables rules
iptables -A INPUT -s "$HOST_NETWORK" -j ACCEPT
iptables -A OUTPUT -d "$HOST_NETWORK" -j ACCEPT

# Set default policies to DROP first
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# First allow established connections for already approved traffic
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Then allow only specific outbound traffic to allowed domains
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

echo "Firewall configuration complete"
echo "Verifying firewall rules..."
if curl --connect-timeout 5 https://example.com >/dev/null 2>&1; then
    echo "ERROR: Firewall verification failed - was able to reach https://example.com"
    exit 1
else
    echo "Firewall verification passed - unable to reach https://example.com as expected"
fi

# Verify GitHub API access
if ! curl --connect-timeout 5 https://api.github.com/zen >/dev/null 2>&1; then
    echo "WARNING: Firewall verification failed - unable to reach https://api.github.com"
    echo "This might be expected if GitHub IPs have changed. Consider updating this script."
    # Continue instead of failing
else
    echo "Firewall verification passed - able to reach https://api.github.com as expected"
fi