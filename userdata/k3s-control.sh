#!/bin/bash
set -euo pipefail

# --- 필요 유틸 설치 (Ubuntu 기준) ---
apt-get update -y || true
apt-get install -y awscli curl ca-certificates || true

aws ssm put-parameter --name "/k3s/cluster-status" --value "initializing" --type String --overwrite --region ap-northeast-2

# --- github manifest repository ssh key ---
mkdir -p ~/.ssh

aws ssm get-parameter \
    --name "/cutty-x-manifest/github-access-ssh-key" \
    --with-decryption \
    --query "Parameter.Value" \
    --region ap-northeast-2 | sed 's/\\n/\n/g' > ~/.ssh/id_ed25519_deploy

chmod 600 ~/.ssh/id_ed25519_deploy

cat <<EOF >> ~/.ssh/config
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_deploy
  IdentitiesOnly yes
EOF

chmod 600 ~/.ssh/config

# --- k3s 서버 설치 ---
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --cluster-init --disable=traefik" sh -

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