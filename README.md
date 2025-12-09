# Infra README

<details open>
<summary>🇰🇷 한국어</summary>

## 📜 개요

이 Terraform 프로젝트는 AWS 상에 완벽한 FaaS(Function-as-a-Service) 플랫폼을 프로비저닝합니다. Terraform Cloud를 사용하여 상태를 관리하고, 모범 사례를 준수하여 설계되었습니다.

## 🏗️ 아키텍처 개요

<img width="5464" height="4592" alt="Image" src="https://github.com/user-attachments/assets/ce4c0424-0f5d-4ef8-9319-65d19acb99f7" />

인프라에는 다음이 포함됩니다:

- **VPC**: 단일 AZ 배포, 퍼블릭/프라이빗 서브넷, NAT 게이트웨이, 인터넷 게이트웨이, VPC 플로우 로그
- **Amplify**: GitHub 리포지토리와의 CI/CD를 통한 프론트엔드 호스팅
- **Cognito**: Google OAuth 제공자를 지원하는 사용자 인증
- **S3**: 3개의 버킷 (프로덕션 코드, 개발 코드, 예비용)
- **CodeBuild**: 도커 이미지 빌드 및 ECR 푸시 자동화
- **DynamoDB**: 함수 메타데이터, 실행 추적, 로그를 위한 3개의 테이블
- **VPC 네트워킹**: 적절한 라우팅 및 DNS를 갖춘 모범 사례 설정
- **Security Groups**: FaaS 워크로드에 맞게 적절히 구성됨
- **SSM Parameter Store**: 중앙 집중식 구성 관리
- **IAM**: 모든 서비스를 위한 포괄적인 역할 및 정책
- **SQS**: 작업 및 결과 큐와 데드 레터 큐(DLQ)
- **Network Load Balancer**: 트래픽 분산을 위한 모듈
- **ECR**: 수명 주기 정책을 갖춘 컨테이너 레지스트리

## 📋 사전 요구 사항

- Terraform >= 1.5.0
- AWS CLI 구성 완료
- Terraform Cloud 계정 (조직: softbank-hackathon-2025-team-green)
- GitHub 개인용 액세스 토큰 (Amplify용)

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
