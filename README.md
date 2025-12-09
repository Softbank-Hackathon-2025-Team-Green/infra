# Infra README

<details open>
<summary>🇰🇷 한국어</summary>

## 📜 개요

이 Terraform 프로젝트는 AWS 상에 FaaS(Function-as-a-Service) 플랫폼을 프로비저닝합니다. Terraform Cloud를 사용하여 상태를 관리하고, 모범 사례를 준수하여 설계되었습니다.
<br>

## 🏗️ 아키텍처 개요

<img src="https://github.com/user-attachments/assets/1dfbe957-dcb4-461f-bf75-64abc58564fa" width="100%">

본 인프라는 Cutty-X FaaS 플랫폼을 구성하기 위한 AWS 기반 인프라로, 플랫폼 전체는 크게 두 개의 Plane으로 나뉜다.
1. **UI & Build Plane** – 사용자 인증, 코드 저장, 빌드 및 함수 배포 트리거
2. **Function Runtime Plane** – EC2 기반 k3s + Knative로 동작하는 경량 FaaS 실행 환경
<br>

## 1️⃣ UI & Build Plane
<img src="https://github.com/user-attachments/assets/cc5788bb-d6b2-4acc-9c4b-49fd3d6239aa" width="50%">

UI & Build Plane은 유저 코드 수집 → 빌드 → 이미지 생성 → 배포 트리거까지의 모든 과정을 처리한다.
Amplify, CodeBuild, S3, DynamoDB, SQS, ECR 등이 유기적으로 연결된다.

### **💠 Cognito – 사용자 인증**

* 플랫폼 UI 접속 및 코드 업로드를 위한 인증/인가 제공
* Amplify Frontend와 직접 통합되어 안전한 사용자 인증 구조 구성

### **💠 AWS Amplify – UI Hosting & API Gateway**

* 사용자 웹 에디터, 대시보드 등 UI 레이어 호스팅
* Cognito 인증과 통합되어 안전한 빌드 요청 처리
* 사용자 코드 제출 시 CodeBuild를 호출하는 엔트리포인트 역할

### **💠 S3 – 유저 코드 및 로그 저장소**

* CodeBuild가 빌드할 소스 코드를 저장
* FluentBit이 수집한 로그를 저장하여 Athena와 연동 가능

### **💠 AWS CodeBuild – Buildpacks 기반 이미지 빌더**

* Cloud Native Buildpacks(pack CLI)을 사용해 **Dockerfile 없이** 유저 코드를 자동 분석·빌드
* 캐싱 최적화로 빌드 시간 약 75% 감소
* 빌드 성공 시 ECR에 이미지 push
* 빌드 결과를 SQS에 전달하여 Knative Service 생성 흐름을 트리거함

### **💠 Amazon SQS – Function Deployment Trigger**

* CodeBuild가 생성한 메타데이터 메시지를 전달
* Runtime Plane의 Queue Polling Agent가 메시지를 읽어 **Knative Service 생성/갱신** 수행

### **💠 Amazon ECR – Function 이미지 저장소**

* Buildpacks로 만들어진 유저 Function 이미지를 저장
* Worker Node가 여기서 pull하여 컨테이너로 실행됨

### **💠 Athena – 로그 분석**

* FluentBit → S3로 전송된 실행 로그를 Athena로 분석 가능
* 함수 모니터링 및 사용량 분석에 활용

<br>

## 2️⃣ Function Runtime Plane
<img src="https://github.com/user-attachments/assets/fdcea309-3755-4e9b-8539-ae44fed1d781" width="60%">


Function Runtime Plane은 실제 FaaS 실행 환경을 담당하며,
**EC2 기반 k3s 클러스터 + Knative**로 구성된다.

구조는 **Control Plane (Single AZ)** + **Worker Node Auto Scaling Group (Multi-AZ)** 형태이다.

### **💠 VPC 구성**

* Public subnet: NLB, NAT, Control Plane
* Private subnet: Worker Node

### **💠 Control Plane (Single-AZ, EC2 k3s Server)**

* 경량 Kubernetes(k3s)의 Control Plane 역할
* Knative System 컴포넌트 일부를 포함 (controller, autoscaler 등)
* 별도 외부 관리형 Kubernetes 없이 EC2 내부에서 자체적으로 구성
* 단일 AZ에 배치해 안정적·일관된 CP 스토리지 보장


### **💠 Worker Node (Multi-AZ, Auto Scaling Group)**

각 노드는 다음과 같은 컴포넌트를 포함한다:

#### Nginx + Kourier
  * 모든 HTTP 요청을 Knative Revision으로 라우팅
  * 동적 path routing 전략을 직접 구현하기 위해 Kourier를 선택적으로 재구성

#### **Queue Polling Agent (SQS Consumer)**

* SQS에 등록된 빌드 완료 메시지를 소비
* Knative Service CRD를 생성하여 실제 함수 런타임 프로비저닝 수행

#### **User Function Pods (Knative Service)**

* Knative Autoscaler(KPA)가 트래픽 기반으로 자동 scale-out / scale-to-zero
* Pod-level Auto-scaling이 Worker Node에서 수평적으로 확장됨

#### **Runtime Sandboxing**

* **gVisor** 기반으로 런타임 샌드박싱 적용
* Multi-tenant 환경에서 Function 간 Isolation 강화

#### **Logging**

* **FluentBit → S3 → Athena** 구조
* 모든 Function 실행 로그가 중앙 집중형 저장소로 수집되어 분석 가능

<br>

## 🛡️ High Availability, Security, Operational Excellence

### **💠 High Availability (고가용성)**

| 구성 요소                | HA 전략                                                   |
| -------------------- | ------------------------------------------------------- |
| **Worker Nodes**     | Multi-AZ ASG 구성 → 한 AZ 장애에도 Function 실행 지속              |
| **NLB**              | Cross-Zone Load Balancing 기반 경로 분산                      |
| **Knative**          | Pod-level auto-scaling 및 scale-to-zero                  |
| **SQS**              | Highly available serverless queue → 메시지 유실 방지           |
| **Build / UI Plane** | Amplify, S3, DynamoDB, Athena 등 모두 fully-managed HA 서비스 |

Control Plane을 Single-AZ로 둔 이유:
* k3s는 SQLite 기반 CP 스토리지가 Multi-AZ 분산에 적합하지 않음
* 대신 Worker Node HA를 보장하여 **실행 환경 가용성**을 확보하는 전략 채택


### **💠 Security**

* **SG 계층 분리**: CP / Worker / ALB / BuildPlane 간 최소 권한 통신만 허용
* **Private Subnet 실행 환경**: 모든 Function Pods는 Private subnet에서만 동작
* **IAM 최소 권한 설계**:
  * BuildPlane은 S3→ECR→SQS 등 필요한 권한만 부여
  * Worker Node는 ECR Pull + SQS Poll 최소 권한만 가짐
* **gVisor Sandbox**를 통한 Function 간 격리


### **💠 Operational Excellence**

* IaC(Terraform Modules) 기반의 완전 자동화된 인프라
* CodeBuild 캐싱 최적화 → 빌드 시간 75% 절감
* Buildpacks 기반 Dockerfile-free 빌드 → 사용자 경험 극대화
* 로그 수집 및 분석 → S3 + Athena 기반 Serverless 분석 파이프라인
* 모든 Knative Service 생성 과정 자동화(SQS → Polling Agent → CRD 생성)

<br>

## 📋 사전 요구 사항

- Terraform >= 1.5.0
- AWS CLI 구성 완료
- Terraform Cloud 계정 (조직: softbank-hackathon-2025-team-green)
- GitHub 개인용 액세스 토큰 (Amplify용)

<br>

## 🚀 빠른 시작

1.  예제 변수 파일 복사:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
2.  `terraform.tfvars`에 자신의 값으로 수정:

    ```hcl
    project_name = "your-project-name"
    environment  = "dev"

    # Amplify를 위한 GitHub 리포지토리 URL 및 토큰 추가
    amplify_repository_url = "https://github.com/your-org/your-repo"
    amplify_access_token = "ghp_your_token_here"

    # Google OAuth로 Cognito 구성
    enable_google_provider = true
    google_client_id = "your-google-client-id.apps.googleusercontent.com"
    google_client_secret = "your-google-client-secret"
    cognito_callback_urls = ["https://your-app.com/callback"]
    ```

3.  Terraform 초기화:
    ```bash
    terraform init
    ```
4.  배포 계획:
    ```bash
    terraform plan
    ```
5.  구성 적용:
    ```bash
    terraform apply
    ```

</details>

<details>
<summary>🇯🇵 日本語</summary>

## 📜 概要

この Terraform プロジェクトは、AWS 上に完全な FaaS（Function-as-a-Service）プラットフォームをプロビジョニングします。Terraform Cloud を使用して状態を管理し、ベストプラクティスに準拠して設計されています。

## 🏗️ アーキテクチャ概要

インフラストラクチャには以下が含まれます：

- **VPC**: 単一 AZ 展開、パブリック/プライベートサブネット、NAT ゲートウェイ、インターネットゲートウェイ、VPC フローログ
- **Amplify**: GitHub リポジトリとの CI/CD によるフロントエンドホスティング
- **Cognito**: Google OAuth プロバイダーをサポートするユーザー認証
- **S3**: 3 つのバケット（本番コード用、開発コード用、予約用）
- **CodeBuild**: Docker イメージのビルドと ECR プッシュの自動化
- **DynamoDB**: 関数メタデータ、実行追跡、ログ用の 3 つのテーブル
- **VPC ネットワーキング**: 適切なルーティングと DNS を備えたベストプラクティスの設定
- **Security Groups**: FaaS ワークロードに合わせて適切に構成
- **SSM Parameter Store**: 集中型の構成管理
- **IAM**: すべてのサービスに対する包括的なロールとポリシー
- **SQS**: タスクおよび結果キューとデッドレターキュー（DLQ）
- **Network Load Balancer**: トラフィック分散用のモジュール
- **ECR**: ライフサイクルポリシーを備えたコンテナレジストリ

## 📋 前提条件

- Terraform >= 1.5.0
- AWS CLI の設定が完了していること
- Terraform Cloud アカウント（組織：softbank-hackathon-2025-team-green）
- GitHub 個人アクセストークン（Amplify 用）

## 🚀 クイックスタート

1.  サンプル変数ファイルをコピー:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
2.  `terraform.tfvars`を自分の値で編集:

    ```hcl
    project_name = "your-project-name"
    environment  = "dev"

    # Amplify用のGitHubリポジトリURLとトークンを追加
    amplify_repository_url = "https://github.com/your-org/your-repo"
    amplify_access_token = "ghp_your_token_here"

    # Google OAuthでCognitoを設定
    enable_google_provider = true
    google_client_id = "your-google-client-id.apps.googleusercontent.com"
    google_client_secret = "your-google-client-secret"
    cognito_callback_urls = ["https://your-app.com/callback"]
    ```

3.  Terraform の初期化:
    ```bash
    terraform init
    ```
4.  デプロイ計画:
    ```bash
    terraform plan
    ```
5.  構成の適用:
    ```bash
    terraform apply
    ```

</details>

<details>
<summary>🇬🇧 English</summary>

## 📜 Overview

This Terraform project provisions a complete Function-as-a-Service (FaaS) platform on AWS. It is designed with best practices and uses Terraform Cloud for state management.

## 🏗️ Architecture Overview

The infrastructure includes:

- **VPC**: Single AZ deployment with public/private subnets, NAT Gateway, Internet Gateway, and VPC Flow Logs
- **Amplify**: Frontend hosting with CI/CD from a GitHub repository
- **Cognito**: User authentication with support for Google OAuth provider
- **S3**: Three buckets (for production code, development code, and reserved use)
- **CodeBuild**: Automation for Docker image building and pushing to ECR
- **DynamoDB**: Three tables for function metadata, execution tracking, and logs
- **VPC Networking**: Best-practice setup with proper routing and DNS
- **Security Groups**: Appropriately configured for FaaS workloads
- **SSM Parameter Store**: Centralized configuration management
- **IAM**: Comprehensive roles and policies for all services
- **SQS**: Task and result queues with Dead Letter Queues (DLQs)
- **Network Load Balancer**: Module for traffic distribution
- **ECR**: Container registry with lifecycle policies

## 📋 Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured
- Terraform Cloud account (organization: softbank-hackathon-2025-team-green)
- GitHub Personal Access Token (for Amplify)

## 🚀 Quick Start

1.  Copy the example variables file:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
2.  Edit `terraform.tfvars` with your values:

    ```hcl
    project_name = "your-project-name"
    environment  = "dev"

    # Add GitHub repository URL and token for Amplify
    amplify_repository_url = "https://github.com/your-org/your-repo"
    amplify_access_token = "ghp_your_token_here"

    # Configure Cognito with Google OAuth
    enable_google_provider = true
    google_client_id = "your-google-client-id.apps.googleusercontent.com"
    google_client_secret = "your-google-client-secret"
    cognito_callback_urls = ["https://your-app.com/callback"]
    ```

3.  Initialize Terraform:
    ```bash
    terraform init
    ```
4.  Plan the deployment:
    ```bash
    terraform plan
    ```
5.  Apply the configuration:
    ```bash
    terraform apply
    ```

</details>
