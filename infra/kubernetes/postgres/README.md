# PostgreSQL Helm Chart 배포 가이드

이 디렉토리는 Kubernetes에 PostgreSQL을 배포하기 위한 Helm 차트 설정 파일을 포함합니다.

## 사전 준비사항

### 1. Helm 설치 확인
```bash
helm version
```

### 2. Bitnami PostgreSQL Helm Repository 추가
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### 3. Kubernetes 클러스터 연결 확인
```bash
kubectl cluster-info
kubectl get nodes
```

## 배포 명령어

### 1. 기본 배포 (Development)

```bash
# Namespace 생성 (선택사항)
kubectl create namespace postgres-airflow

# PostgreSQL 배포
helm install postgresql bitnami/postgresql \
  -f /DATA/app/infra/kubernetes/postgres/values-postgres.yaml \
  -n postgres-airflow

# 또는 기본 namespace에 배포
helm install postgresql bitnami/postgresql \
  -f infra/kubernetes/postgres/values-postgres.yaml
```

### 2. 특정 버전으로 배포

```bash
# 특정 차트 버전 확인
helm search repo bitnami/postgresql --versions

# 특정 버전으로 배포
helm install postgresql bitnami/postgresql \
  --version 15.5.0 \
  -f infra/kubernetes/postgres/values-postgres.yaml \
  -n database
```

### 3. Dry-run으로 확인 (실제 배포 전 검증)

```bash
helm install postgresql bitnami/postgresql \
  -f /DATA/app/infra/kubernetes/postgres/values-postgres.yaml \
  -n database \
  --dry-run --debug
```

### 4. 기존 배포 업그레이드

```bash
# 설정 변경 후 업그레이드
helm upgrade postgresql bitnami/postgresql \
  -f infra/kubernetes/postgres/values-postgres.yaml \
  -n database

# 강제 재시작
helm upgrade postgresql bitnami/postgresql \
  -f infra/kubernetes/postgres/values-postgres.yaml \
  -n database \
  --force
```

## 배포 상태 확인

### 1. Helm 릴리스 확인
```bash
# 릴리스 목록
helm list -n database

# 릴리스 상세 정보
helm status postgresql -n database

# 릴리스 히스토리
helm history postgresql -n database
```

### 2. Pod 상태 확인
```bash
# Pod 목록
kubectl get pods -n database

# Pod 상세 정보
kubectl describe pod postgresql-0 -n database

# Pod 로그 확인
kubectl logs -f postgresql-0 -n database

# Metrics Pod 로그
kubectl logs -f postgresql-metrics-xxxxxxxxx -n database
```

### 3. Service 확인
```bash
# Service 목록
kubectl get svc -n database

# Service 상세 정보
kubectl describe svc postgresql -n database
```

### 4. PVC (Persistent Volume Claim) 확인
```bash
# PVC 목록
kubectl get pvc -n database

# PVC 상세 정보
kubectl describe pvc data-postgresql-0 -n database
```

## 데이터베이스 접속

### 1. 비밀번호 확인
```bash
# PostgreSQL admin 비밀번호
export POSTGRES_PASSWORD=$(kubectl get secret --namespace database postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
echo $POSTGRES_PASSWORD

# App user 비밀번호
export APP_PASSWORD=$(kubectl get secret --namespace database postgresql -o jsonpath="{.data.password}" | base64 -d)
echo $APP_PASSWORD
```

### 2. 클러스터 내부에서 접속
```bash
# PostgreSQL 클라이언트 Pod 실행
kubectl run postgresql-client --rm --tty -i --restart='Never' \
  --namespace database \
  --image docker.io/bitnami/postgresql:17.3.0-debian-12-r0 \
  --env="PGPASSWORD=$POSTGRES_PASSWORD" \
  --command -- psql --host postgresql -U postgres -d masters_eye_dev -p 5432
```

### 3. 로컬에서 Port Forward로 접속
```bash
# Port forwarding
kubectl port-forward --namespace database svc/postgresql 5432:5432 &

# psql로 접속
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d masters_eye_dev -p 5432

# 또는 GUI 툴(DBeaver, pgAdmin 등)에서 접속
# Host: localhost
# Port: 5432
# Database: masters_eye_dev
# Username: postgres 또는 app_user
# Password: (위에서 확인한 비밀번호)
```

## 트러블슈팅

### Pod이 시작되지 않을 때
```bash
# Pod 이벤트 확인
kubectl describe pod postgresql-0 -n database

# Pod 로그 확인
kubectl logs postgresql-0 -n database

# 이전 컨테이너 로그 확인 (재시작된 경우)
kubectl logs postgresql-0 -n database --previous
```

### PVC 문제 해결
```bash
# PVC 상태 확인
kubectl get pvc -n database

# StorageClass 확인
kubectl get storageclass

# PV 확인
kubectl get pv
```

### 연결 문제 해결
```bash
# Service endpoint 확인
kubectl get endpoints postgresql -n database

# Network policy 확인 (활성화된 경우)
kubectl get networkpolicy -n database

# DNS 확인
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup postgresql.database.svc.cluster.local
```

## 백업 및 복구

### 수동 백업
```bash
# Pod 내부에서 백업
kubectl exec -it postgresql-0 -n database -- bash
pg_dump -U postgres masters_eye_dev > /tmp/backup.sql

# 로컬로 복사
kubectl cp database/postgresql-0:/tmp/backup.sql ./backup.sql
```

### 수동 복구
```bash
# 백업 파일을 Pod로 복사
kubectl cp ./backup.sql database/postgresql-0:/tmp/backup.sql

# Pod 내부에서 복구
kubectl exec -it postgresql-0 -n database -- bash
psql -U postgres masters_eye_dev < /tmp/backup.sql
```

## 삭제

### PostgreSQL 삭제 (데이터는 유지)
```bash
# Helm 릴리스만 삭제
helm uninstall postgresql -n database

# PVC는 남아있어서 데이터 보존됨
kubectl get pvc -n database
```

### 완전 삭제 (데이터 포함)
```bash
# Helm 릴리스 삭제
helm uninstall postgresql -n database

# PVC 삭제 (데이터 손실!)
kubectl delete pvc data-postgresql-0 -n database

# Namespace 삭제 (모든 리소스 삭제)
kubectl delete namespace database
```

## 프로덕션 배포 시 주의사항

### 1. Secret 생성 (필수)
```bash
# PostgreSQL Secret 생성
kubectl create secret generic postgresql-secret \
  --from-literal=postgres-password='YOUR_STRONG_PASSWORD' \
  --from-literal=password='YOUR_APP_PASSWORD' \
  --from-literal=replication-password='YOUR_REPLICATION_PASSWORD' \
  -n database
```

### 2. StorageClass 확인 및 설정
```bash
# 사용 가능한 StorageClass 확인
kubectl get storageclass

# values 파일에서 적절한 StorageClass 지정
# storageClass: "gp3"  # AWS
# storageClass: "fast-ssd"  # GCP
```

### 3. Resource 조정
- CPU/Memory 요청 및 제한을 서버 사양에 맞게 조정
- PVC 크기를 데이터 규모에 맞게 조정

### 4. 모니터링 설정
- Prometheus Operator 사용 시 `metrics.serviceMonitor.enabled: true` 설정
- Grafana 대시보드 연동

### 5. 백업 전략 수립
- 자동 백업 크론잡 설정 또는 외부 백업 솔루션 사용 (Velero, pgBackRest 등)

## 설정 파일 구조

- `values-postgres.yaml`: 개발 환경용 설정 파일
- README.md: 배포 가이드 (이 파일)

## 참고 문서

- [Bitnami PostgreSQL Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)
- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)