#!/bin/bash
set -euo pipefail

# --- 필요 유틸 설치 (Ubuntu 기준) ---
apt-get update -y || true
apt-get install -y awscli curl ca-certificates || true

aws ssm put-parameter --name "/k3s/cluster-status" --value "initializing" --type String --overwrite --region ap-northeast-2

# --- k3s 서버 설치 ---
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --cluster-init" sh -

# node-token 파일 생성될 때까지 대기
for i in {1..20}; do
  if [ -f /var/lib/rancher/k3s/server/node-token ]; then
    break
  fi
  echo "Waiting for k3s node-token..."
  sleep 3
done

TOKEN=$(tr -d '\n' < /var/lib/rancher/k3s/server/node-token)


# --- SSM Parameter Store 에 저장 ---
aws ssm put-parameter \
  --region "ap-northeast-2" \
  --name "/k3s/cluster-token" \
  --type "SecureString" \
  --value "${TOKEN}" \
  --overwrite

echo "k3s token stored to SSM Parameter Store"

aws ssm put-parameter --name "/k3s/cluster-status" --value "ready" --type String --overwrite --region ap-northeast-2