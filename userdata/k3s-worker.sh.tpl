#!/bin/bash
set -euo pipefail

apt-get update -y || true
apt-get install -y awscli curl ca-certificates || true

echo "Waiting for CP to be ready..."

STATUS=""

while true; do
  if STATUS=$(aws ssm get-parameter \
        --name "/k3s/cluster-status" \
        --query "Parameter.Value" \
        --output text \
        --region "ap-northeast-2" ); then
    echo "Current CP status from SSM: $STATUS"
  else
    echo "cluster-status parameter not found yet. Waiting..."
    STATUS="not-found"
  fi

  if [ "$STATUS" = "ready" ]; then
    echo "CP is ready! Proceeding..."
    break
  else
    echo "CP status is '$STATUS'. Waiting 10 seconds..."
    sleep 10
  fi
done


SERVER_IP="${server_ip}"
SERVER_URL="https://${SERVER_IP}:6443"

TOKEN=$(aws ssm get-parameter \
  --region "ap-northeast-2" \
  --name "/k3s/cluster-token" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

echo "Fetched SERVER_URL=$SERVER_URL"
echo "Fetched TOKEN length: $${#TOKEN}"

curl -sfL https://get.k3s.io | \
  K3S_URL="$SERVER_URL" \
  K3S_TOKEN="$TOKEN" \
  INSTALL_K3S_EXEC="agent" \
  sh -

echo "k3s agent joined successfully."
