📈 프로젝트: 대가의 눈 (The Master's Eye)
워런 버핏, 레이 달리오와 같은 전설적인 투자 대가들의 관점에서 한국 주식을 분석하고 추천하는 서비스입니다. 본 프로젝트는 최신 금융 데이터를 기반으로, 특정 투자 전문가의 철학과 원칙을 LLM(거대 언어 모델)과 RAG(검색 증강 생성) 기술을 통해 적용하여 심층적인 투자 분석 리포트를 제공하는 것을 목표로 합니다.

✨ 주요 기능
투자 대가 선택: 분석을 원하는 투자 전문가(워런 버핏, 레이 달리오 등)를 선택할 수 있습니다.

종목 분석 요청: 국내 상장 주식 종목을 입력하여 분석을 요청합니다.

AI 기반 분석 리포트: 선택한 대가의 투자 철학에 입각하여 생성된 AI 분석 리포트를 확인합니다.

주기적인 데이터 업데이트: Airflow를 통해 금융 데이터가 주기적으로 자동 업데이트됩니다.
ㅈ
🛠️ 기술 스택 및 인프라 (Tech Stack & Infrastructure)
본 프로젝트는 컨테이너 기반의 MSA(마이크로서비스 아키텍처)를 지향하며, 자체 서버에 쿠버네티스 클러스터를 구축하여 운영됩니다.

🖥️ 인프라 (Infrastructure)

OS: Rocky Linux 9.x

Orchestration: Kubernetes (k3s)

Containerization: Docker

Web Server / Ingress: Nginx, Traefik

⚙️ 백엔드 (Backend)

Framework: FastAPI (Python 3.10+)

AI/LLM Core: OpenAI GPT-4/Google Gemini API 연동, LangChain

Technique: RAG (Retrieval-Augmented Generation)

🎨 프론트엔드 (Frontend)

Framework: Vue.js 3

Build Tool: Vite

💾 데이터베이스 (Database)

Relational Database: MariaDB (기업 재무 정보, 주가 등 저장)

Vector Database: ChromaDB (투자 철학 임베딩 데이터 저장)

🔄 데이터 파이프라인 (Data Pipeline)

Orchestration: Apache Airflow

🔧 개발 및 버전 관리 (DevOps & Version Control)

Version Control: Git

Repository Strategy: Monorepo

Deployment: Kubernetes Manifests (YAML)

📁 디렉토리 구조
프로젝트는 모노레포 방식으로 구성되어 있으며, 각 컴포넌트는 다음과 같이 디렉토리로 분리됩니다.

.
├── airflow/                      # Airflow DAG 및 관련 설정
├── backend/                      # FastAPI 백엔드 애플리케이션
├── frontend/                     # Vue.js 프론트엔드 애플리케이션
├── infra/                        # 쿠버네티스 배포를 위한 모든 YAML Manifest 파일
├── .gitignore                    # Git 버전 관리 제외 목록
├── docker-compose.yml            # 로컬 개발 환경 실행을 위한 설정
└── README.md                     # 프로젝트 문서
airflow/: 데이터 수집 및 처리를 위한 Airflow DAG 스크립트가 위치합니다.

backend/: LLM 연동 및 API 로직을 포함하는 FastAPI 서버의 소스 코드가 위치합니다.

frontend/: 사용자가 상호작용하는 웹 화면을 구성하는 Vue.js 소스 코드가 위치합니다.

infra/: Kubernetes 클러스터에 각 컴포넌트를 배포하기 위한 Deployment, Service, Ingress 등의 YAML 파일들이 위치합니다.

🚀 시작하기 (Getting Started)
사전 준비물

Git

Docker & Docker Compose

kubectl

Helm

로컬 개발 환경 실행

로컬 환경에서 각 서비스를 테스트하기 위해 docker-compose.yml을 사용합니다.

Bash
# 1. 레포지토리 클론
git clone <레포지토리_주소>
cd <프로젝트_디렉토리>

# 2. .env 파일 생성 및 API 키 등 환경 변수 설정
# (필요 시 .env.example 파일을 참고하여 작성)

# 3. Docker Compose를 사용하여 모든 서비스 실행
docker-compose up --build -d
서버 배포

서버 배포는 infra/kubernetes/ 디렉토리의 Manifest 파일을 통해 진행됩니다.

Bash
# 각 컴포넌트의 YAML 파일을 순서대로 쿠버네티스 클러스터에 적용
kubectl apply -f infra/kubernetes/database/mariadb.yaml
kubectl apply -f infra/kubernetes/webapp/fastapi-deployment.yaml
# ...
🌿 브랜칭 전략 (Branching Strategy)
main: 실제 서버에 배포되는 안정적인 브랜치입니다.

develop: 다음 출시를 위한 기능 통합 브랜치입니다.

feature/<기능이름>: 개별 기능 개발을 위한 브랜치이며, develop에서 생성하고 develop으로 병합합니다.

✍️ 커밋 컨벤션 (Commit Convention)
프로젝트의 커밋 메시지는 Conventional Commits 규칙을 따르는 것을 권장합니다.

예시: feat(backend): 워런 버핏 투자 전략 분석 API 추가