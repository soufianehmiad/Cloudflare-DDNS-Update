#!/bin/bash

# Function to log messages
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Load configuration from config.json
CONFIG_FILE="/opt/ddns/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
  log "Error: Configuration file $CONFIG_FILE not found."
  exit 1
fi

# Read configuration values
auth_email=$(jq -r '.cloudflare.auth_email' "$CONFIG_FILE")
auth_method=$(jq -r '.cloudflare.auth_method' "$CONFIG_FILE")
auth_key=$(jq -r '.cloudflare.auth_key' "$CONFIG_FILE")
websites=$(jq -c '.websites[]' "$CONFIG_FILE")

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  log "Error: 'jq' is required but not installed. Please install it (e.g., sudo apt-get install jq)."
  exit 1
fi

# Loop through websites
while IFS= read -r website; do
  domain=$(echo "$website" | jq -r '.domain')
  record_name=$(echo "$website" | jq -r '.record_name')
  sitename=$(echo "$website" | jq -r '.sitename')
  subdomain=$(echo "$website" | jq -r '.subdomain')
  zone_identifier=$(echo "$website" | jq -r '.zone_identifier')
  ttl=$(echo "$website" | jq -r '.ttl')
  proxy=$(echo "$website" | jq -r '.proxy')

  # Get current IP address
  current_ip=$(curl -s http://ipv4.icanhazip.com)

  # Retrieve DNS record ID from Cloudflare
  record_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name" \
                      -H "X-Auth-Email: $auth_email" \
                      -H "X-Auth-Key: $auth_key" \
                      -H "Content-Type: application/json" | jq -r '.result[0].id')

  # Check if the record exists
  if [ -z "$record_id" ]; then
    log "Error: DNS record for $record_name does not exist."
    continue
  fi

  # Retrieve current IP address from the DNS record
  dns_ip=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_id" \
                      -H "X-Auth-Email: $auth_email" \
                      -H "X-Auth-Key: $auth_key" \
                      -H "Content-Type: application/json" | jq -r '.result.content')

  # Check if the DNS record IP matches the current IP
  if [ "$dns_ip" = "$current_ip" ]; then
    log "DNS record for $domain ($subdomain) is up-to-date. No action needed."
    continue
  fi

  # Update DNS record with current IP
  response=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_id" \
                      -H "X-Auth-Email: $auth_email" \
                      -H "X-Auth-Key: $auth_key" \
                      -H "Content-Type: application/json" \
                      --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$current_ip\",\"ttl\":$ttl,\"proxied\":$proxy}")

  # Check if the update was successful
  success=$(echo "$response" | jq -r '.success')
  if [ "$success" = "true" ]; then
    log "DNS record for $domain ($subdomain) updated to $current_ip."
  else
    log "Error: Failed to update DNS record for $domain ($subdomain)."
    log "Response: $response"
  fi

done <<< "$websites"

log "All DNS records updated successfully."
