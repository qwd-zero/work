#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")/.."
recovery_port=${1:-8083}
if (( $# > 1 )) || [[ ! $recovery_port =~ ^[1-9][0-9]{0,4}$ ]] || (( recovery_port > 65535 || recovery_port == 8080 )); then
  echo '사용법: bash scripts/verify-evidence.sh [8080과 다른 대체 포트]' >&2
  exit 2
fi

if ! docker info --format '{{.ServerVersion}}' >/dev/null; then
  echo 'Docker Desktop을 시작하고 WSL 터미널에서 docker info를 확인하세요.' >&2
  exit 1
fi

mkdir -p logs
work=$(mktemp -d logs/.codyssey-check.XXXXXXXX)
prefix=codyssey-check-${work##*.}
label="codyssey.evidence=$prefix"
volume="$prefix-data"
image=codyssey-web:1.0

cleanup() {
  local status=$?
  if (( status != 0 )) && [[ -s $work/session.txt ]]; then
    tail -n 18 "$work/session.txt" >&2
  fi
  # 이 실행에서 붙인 레이블로만 정리한다. 8080을 먼저 사용하던 서비스는 계속 실행된다.
  docker ps -aq --filter "label=$label" | xargs -r docker rm -f >/dev/null || true
  docker volume ls -q --filter "label=$label" | xargs -r docker volume rm >/dev/null || true
  rm -rf -- "$work"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

run_web() {
  docker run -d --name "$prefix-$1" --label "$label" -p "127.0.0.1:$2:80" "$image"
}

echo "볼륨 삭제 전후와 8080 → $recovery_port 포트 복구를 확인합니다."
(
  set -x
  date -Iseconds
  docker version --format 'Docker {{.Server.Version}}'
  if ! docker image inspect "$image" >/dev/null 2>&1; then
    docker build -t "$image" .
  fi

  docker volume create --label "$label" "$volume"
  owner=$(docker volume inspect --format '{{index .Labels "codyssey.evidence"}}' "$volume")
  [[ $owner == "$prefix" ]]
  docker run --name "$prefix-writer" --label "$label" -v "$volume:/data" \
    --entrypoint sh "$image" -ec 'echo "Codyssey Persistent Data" > /data/message.txt
cat /data/message.txt' > "$work/before"
  cat "$work/before"
  docker rm "$prefix-writer"
  docker ps -a --filter "name=^/${prefix}-writer$" --format 'table {{.Names}}\t{{.Status}}'
  docker run --rm --label "$label" -v "$volume:/data:ro" \
    --entrypoint cat "$image" /data/message.txt > "$work/after"
  cat "$work/after"
  grep -Fxq 'Codyssey Persistent Data' "$work/before"
  cmp "$work/before" "$work/after"

  # 8080이 비어 있으면 첫 컨테이너가 점유한다. 이미 사용 중이면 첫 시도에서 충돌이 기록된다.
  if run_web first 8080 > "$work/conflict" 2>&1; then
    cat "$work/conflict"
    if run_web second 8080 > "$work/conflict" 2>&1; then
      echo '8080 충돌을 재현하지 못했습니다.' >&2
      exit 1
    fi
  fi
  cat "$work/conflict"
  grep -Eiq 'port is already allocated|address already in use|only one usage of each socket address' "$work/conflict"
  docker ps --format 'table {{.Names}}\t{{.Ports}}' | awk 'NR == 1 || /:8080->/'
  if command -v ss >/dev/null; then
    ss -ltnp 'sport = :8080'
  fi

  if ! run_web recovery "$recovery_port"; then
    echo '대체 포트도 사용 중이면 다른 번호로 실행하세요. 예: bash scripts/verify-evidence.sh 8084' >&2
    exit 1
  fi
  docker port "$prefix-recovery" 80/tcp
  code=$(curl --noproxy '*' -sS --retry 8 --retry-all-errors --retry-delay 1 \
    --connect-timeout 2 --max-time 5 -D "$work/headers" -o "$work/body" \
    -w '%{http_code}' "http://127.0.0.1:$recovery_port/")
  cat "$work/headers" "$work/body"
  if [[ $code != 200 ]]; then
    echo "HTTP 응답 코드가 $code입니다. 웹 서버 로그를 확인하세요." >&2
    exit 1
  fi
  if ! cmp site/index.html "$work/body"; then
    echo '응답 본문이 소스와 다릅니다. docker build -t codyssey-web:1.0 . 으로 이미지를 갱신하세요.' >&2
    exit 1
  fi
  set +x
  echo "볼륨 내용 일치 / 포트 $recovery_port HTTP $code / site/index.html 본문 일치"
) > "$work/session.txt" 2>&1

mv -- "$work/session.txt" logs/workstation-verification.txt
echo '저장 완료: logs/workstation-verification.txt'
