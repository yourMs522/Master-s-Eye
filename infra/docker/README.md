# Master's Eye - Docker Infrastructure

이 디렉토리는 Master's Eye 프로젝트의 로컬 개발 환경을 위한 Docker 구성을 포함합니다.

## 구성 요소

- **Apache Airflow**: 워크플로우 관리 및 스케줄링
- **PostgreSQL**: Airflow 메타데이터 저장소
- **MariaDB**: Mart 데이터베이스

## 사전 요구사항

- Docker Engine 20.10 이상
- Docker Compose V2 이상
- 최소 4GB 이상의 여유 메모리

## 설치 및 실행

### 1. 환경 변수 설정

`.env.example` 파일을 복사하여 `.env` 파일을 생성합니다:

```bash
cd infra/docker
cp .env.example .env
```

필요에 따라 `.env` 파일의 값을 수정합니다.

### 2. Airflow 디렉토리 구조 생성

```bash
mkdir -p airflow/{dags,logs,plugins,config}
```

### 3. MariaDB 초기화 스크립트 디렉토리 생성 (선택사항)

```bash
mkdir -p mariadb/init
```

필요한 경우 `mariadb/init` 디렉토리에 `.sql` 파일을 추가하여 초기 데이터베이스 스키마를 설정할 수 있습니다.

### 4. Docker Compose 실행

```bash
# 모든 서비스 시작
docker compose up -d

# 로그 확인
docker compose logs -f

# 특정 서비스만 시작
docker compose up -d postgres-airflow mariadb-mart
```

### 5. 서비스 확인

- **Airflow Web UI**: http://localhost:8080
  - 기본 계정: `airflow` / `airflow` (`.env` 파일에서 변경 가능)
- **PostgreSQL**: `localhost:5432`
  - 데이터베이스: `airflow`
  - 사용자: `airflow`
- **MariaDB**: `localhost:3306`
  - 데이터베이스: `mart_db`
  - 사용자: `mart_user`

## 서비스 관리

### 서비스 중지

```bash
docker compose stop
```

### 서비스 재시작

```bash
docker compose restart
```

### 서비스 완전 삭제 (데이터 포함)

```bash
docker compose down -v
```

### 서비스 완전 삭제 (데이터 유지)

```bash
docker compose down
```

## Airflow CLI 사용

Airflow CLI를 사용하려면 다음 명령어를 실행합니다:

```bash
# DAG 목록 확인
docker compose run --rm airflow-cli dags list

# 변수 설정
docker compose run --rm airflow-cli variables set KEY VALUE

# 연결 설정
docker compose run --rm airflow-cli connections add 'my_conn' \
  --conn-type 'mysql' \
  --conn-host 'mariadb-mart' \
  --conn-login 'mart_user' \
  --conn-password 'mart_password' \
  --conn-port 3306 \
  --conn-schema 'mart_db'
```

## 데이터베이스 접속

### PostgreSQL 접속

```bash
docker compose exec postgres-airflow psql -U airflow -d airflow
```

### MariaDB 접속

```bash
docker compose exec mariadb-mart mysql -u mart_user -p mart_db
```

## 디렉토리 구조

```
infra/docker/
├── docker-compose.yml      # Docker Compose 설정 파일
├── .env                     # 환경 변수 (gitignore에 추가 권장)
├── .env.example             # 환경 변수 예제
├── README.md                # 이 파일
├── airflow/                 # Airflow 관련 파일
│   ├── dags/                # DAG 파일
│   ├── logs/                # 로그 파일
│   ├── plugins/             # 플러그인
│   └── config/              # 설정 파일
└── mariadb/                 # MariaDB 관련 파일
    └── init/                # 초기화 SQL 스크립트
```

## 환경 변수

주요 환경 변수는 다음과 같습니다:

| 변수명 | 설명 | 기본값 |
|--------|------|--------|
| `AIRFLOW_UID` | Airflow 실행 사용자 ID | `50000` |
| `AIRFLOW_DB_PASSWORD` | Airflow PostgreSQL 비밀번호 | `airflow` |
| `_AIRFLOW_WWW_USER_USERNAME` | Airflow 웹 UI 사용자명 | `airflow` |
| `_AIRFLOW_WWW_USER_PASSWORD` | Airflow 웹 UI 비밀번호 | `airflow` |
| `MARIADB_ROOT_PASSWORD` | MariaDB root 비밀번호 | `rootpassword` |
| `MARIADB_DATABASE` | MariaDB 데이터베이스 이름 | `mart_db` |
| `MARIADB_USER` | MariaDB 사용자명 | `mart_user` |
| `MARIADB_PASSWORD` | MariaDB 사용자 비밀번호 | `mart_password` |

## 문제 해결

### Airflow 초기화 실패

권한 문제가 발생할 수 있습니다. 다음 명령어로 해결할 수 있습니다:

```bash
sudo chown -R $USER:$USER airflow/
```

### 포트 충돌

이미 사용 중인 포트가 있다면 `docker-compose.yml`에서 포트를 변경합니다:

```yaml
ports:
  - "8081:8080"  # Airflow (8080 -> 8081로 변경)
  - "5433:5432"  # PostgreSQL (5432 -> 5433으로 변경)
  - "3307:3306"  # MariaDB (3306 -> 3307로 변경)
```

### 컨테이너 로그 확인

```bash
# 모든 서비스 로그
docker compose logs -f

# 특정 서비스 로그
docker compose logs -f airflow-webserver
docker compose logs -f postgres-airflow
docker compose logs -f mariadb-mart
```

## 보안 고려사항

프로덕션 환경에서는 다음 사항을 반드시 변경해야 합니다:

1. 모든 기본 비밀번호 변경
2. `.env` 파일을 `.gitignore`에 추가
3. 강력한 Fernet Key 설정 (`AIRFLOW__CORE__FERNET_KEY`)
4. 네트워크 접근 제어 설정
5. SSL/TLS 인증서 적용

## 추가 정보

- [Apache Airflow 공식 문서](https://airflow.apache.org/docs/)
- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)
- [MariaDB 공식 문서](https://mariadb.org/documentation/)
