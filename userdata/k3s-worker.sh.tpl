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


SERVER_IP="${server_private_ip}"
SERVER_URL="https://$${SERVER_IP}:6443"

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

echo installing gVisor...

#1. 최신 버전 URL 설정
ARCH=$(uname -m)
URL="https://storage.googleapis.com/gvisor/releases/release/latest/$${ARCH}"

# 2. runsc 다운로드 (curl -L -O 옵션 사용)
curl -L -O ${URL}/runsc
curl -L -O ${URL}/runsc.sha512

# 3. 무결성 검증
sha512sum -c runsc.sha512 -w

# 4. 실행 권한 부여 및 이동
chmod a+rx runsc
sudo mv runsc /usr/local/bin

# 5. containerd-shim-runsc-v1 다운로드
curl -L -O ${URL}/containerd-shim-runsc-v1
curl -L -O ${URL}/containerd-shim-runsc-v1.sha512

# 6. 무결성 검증 및 설치
sha512sum -c containerd-shim-runsc-v1.sha512 -w
chmod a+rx containerd-shim-runsc-v1
sudo mv containerd-shim-runsc-v1 /usr/local/bin

#########################
# k3s의 containerd와 gVisor runsc 연결
##########################
# 1. 설정 템플릿 디렉토리 확인 (없으면 생성)
sudo mkdir -p /var/lib/rancher/k3s/agent/etc/containerd/

# 2. 네트워크 설정파일 템플릿 복사
cp /var/lib/rancher/k3s/agent/etc/containerd/config.toml \
   /var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl

# 3. gVisor Runtime만 뒤에 집어넣기
cat << 'EOF' >> /var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl

[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
EOF

# 4. 새로운 config 파일로 시작할 수 있도록 기존 config파일 삭제
rm -f /var/lib/rancher/k3s/agent/etc/containerd/config.toml

# 5. K3s 에이전트 재시작
sudo systemctl restart k3s-agent

#########################
# 설치 확인
##########################
# 설치된 runsc 버전 확인
runsc --version

# K3s가 인식했는지 확인
crictl info | grep runsc
