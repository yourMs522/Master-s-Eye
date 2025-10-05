#!/bin/bash

# Airflow Helm Chart를 사용한 쿠버네티스 배포 스크립트 (Rocky Linux)

set -e

# 변수 설정
NAMESPACE="airflow"
RELEASE_NAME="airflow"
HELM_REPO="https://airflow.apache.org"
CHART_NAME="apache-airflow/airflow"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Airflow 쿠버네티스 배포 시작..."

# 1. Airflow Helm Repository 추가
echo "📦 Airflow Helm Repository 추가 중..."
helm repo add apache-airflow ${HELM_REPO} 2>/dev/null || helm repo add apache-airflow ${HELM_REPO}
helm repo update

# 2. Namespace 생성
echo "📁 Namespace '${NAMESPACE}' 생성 중..."
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# 3. values.yaml 파일 존재 확인
if [ ! -f "${SCRIPT_DIR}/values.yaml" ]; then
    echo "⚙️  기본 values.yaml 파일 생성 중..."
    helm show values ${CHART_NAME} > "${SCRIPT_DIR}/values.yaml"
    echo "✅ values.yaml 파일이 생성되었습니다."
    echo "📝 DAGs 경로 및 데이터베이스 설정을 수정 후 다시 실행하세요."
    echo ""
    echo "주요 설정 항목:"
    echo "  - dags.gitSync: DAGs Git 저장소 설정"
    echo "  - postgresql/mariadb: 외부 DB 연결 설정"
    echo "  - executor: KubernetesExecutor 또는 CeleryExecutor"
    exit 0
fi

# 4. Airflow Helm Chart 설치
echo "🔧 Airflow Helm Chart 설치 중..."
helm upgrade --install ${RELEASE_NAME} ${CHART_NAME} \
    --namespace ${NAMESPACE} \
    --values "${SCRIPT_DIR}/values.yaml" \
    --timeout 10m

# 5. 배포 상태 확인
echo "⏳ Airflow Pod 상태 확인 중..."
kubectl wait --for=condition=ready pod \
    -l app.kubernetes.io/name=airflow \
    -n ${NAMESPACE} \
    --timeout=600s 2>/dev/null || echo "⚠️  일부 Pod가 아직 준비되지 않았습니다. 수동으로 확인하세요."

echo ""
echo "✅ Airflow 배포가 완료되었습니다!"
echo ""
echo "📋 배포 정보:"
echo "  - Namespace: ${NAMESPACE}"
echo "  - Release: ${RELEASE_NAME}"
echo "  - 설치 경로: ${SCRIPT_DIR}"
echo ""
echo "🔍 서비스 상태 확인:"
echo "  kubectl get pods -n ${NAMESPACE}"
echo "  kubectl get svc -n ${NAMESPACE}"
echo ""
echo "🌐 Airflow Webserver 접속 (로키 서버):"
echo "  # NodePort 또는 Ingress를 통한 접속"
echo "  kubectl get svc ${RELEASE_NAME}-webserver -n ${NAMESPACE}"
echo ""
echo "📊 기본 로그인 정보:"
echo "  Username: admin"
echo "  Password: kubectl get secret --namespace ${NAMESPACE} ${RELEASE_NAME}-webserver -o jsonpath=\"{.data.admin-password}\" | base64 --decode"
