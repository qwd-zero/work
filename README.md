
# Codyssey Development Workstation

## 1. 프로젝트 개요

Linux CLI, Docker, Git 및 GitHub를 활용하여
재현 가능한 개발 워크스테이션을 구축한다.

주요 목표:
- Linux 터미널 및 권한 관리
- Docker 설치 및 컨테이너 운영
- Dockerfile 기반 웹 서버 구현
- 포트 매핑과 브라우저 접속 검증
- 바인드 마운트 및 볼륨 영속성 실습
- Git 및 GitHub 기반 버전 관리

## 2. 실행 환경

| 항목 | 실제 실행 환경 |
|---|---|
| Host OS | Windows 버전 입력 |
| Linux | Ubuntu 버전 입력 (WSL 2) |
| Shell | bash |
| Terminal | VS Code Integrated Terminal |
| Docker | 실제 버전 입력 |
| Git | 실제 버전 입력 |

Docker 설치/점검:
- [버전 로그](logs/docker-version.txt)
- [Docker 정보](logs/docker-info.txt)
- [hello-world 결과](logs/hello-world.txt)

## 3. 수행 체크리스트

- [x] Linux 터미널 조작
- [x] 디렉터리 및 파일 관리
- [x] chmod 권한 변경
- [x] Docker 설치 및 실행 확인
- [x] Docker 운영 명령 실습
- [x] Dockerfile 이미지 빌드
- [x] 포트 8080 접속 검증
- [x] 포트 8081 접속 검증
- [x] 바인드 마운트 변경 반영
- [x] Docker 볼륨 영속성 확인
- [x] Git 설정
- [x] VS Code 및 GitHub 연동

## 4. Linux 터미널 및 권한 관리

수행 명령:
- pwd, whoami, ls, mkdir
- chmod 640 permission-test.txt

증거:
- [터미널 로그](logs/terminal-basics.txt)
- [권한 변경 로그](logs/permission.txt)

## 5. Docker 운영 검증

수행 명령:
- docker --version
- docker info
- docker run --rm hello-world
- docker images
- docker ps -a
- docker logs
- docker stats --no-stream

검증 결과:
- [Docker 이미지 목록](logs/docker-images.txt)
- [컨테이너 목록](logs/docker-ps.txt)
- [실행 로그](logs/docker-logs.txt)
- [리소스 사용량](logs/docker-stats.txt)

## 6. Dockerfile 웹 서버

웹 서버: Nginx

이미지 빌드:

docker build -t codyssey-web:1.0 .

검증:
- [Dockerfile](Dockerfile)
- [웹 서버 소스](site/index.html)
- [이미지 빌드 로그](logs/docker-build.txt)

## 7. 포트 매핑 검증

8080 포트:
- [실행 로그](logs/run-8080.txt)
- [HTTP 응답](logs/port-8080.txt)

![8080 포트 접속](evidence/port-8080.png)

8081 포트:
- [실행 로그](logs/run-8081.txt)
- [HTTP 응답](logs/port-8081.txt)

![8081 포트 접속](evidence/port-8081.png)

## 8. 바인드 마운트 검증

호스트의 live/index.html을 컨테이너에 연결.

검증:
- [실행 로그](logs/bind-run.txt)
- [변경 전 응답](logs/bind-before.txt)
- [변경 후 응답](logs/bind-after.txt)

변경 전:
![변경 전](evidence/bind-before.png)

변경 후:
![변경 후](evidence/bind-after.png)

결과: 호스트 파일 수정 후 재빌드 없이 반영.

## 9. Docker 볼륨 영속성

볼륨 이름: codyssey-data

검증:
- [볼륨 생성](logs/volume-created.txt)
- [삭제 전 데이터](logs/volume-before.txt)
- [컨테이너 삭제](logs/volume-container-deleted.txt)
- [재생성 후 데이터](logs/volume-after.txt)

결과: 컨테이너 삭제 후에도 파일 유지.

## 10. 트러블슈팅

### 사례 1. 포트 충돌

- 문제: 실제 오류 내용 작성
- 원인 가설: 8080 포트 중복 사용
- 확인: docker ps -a
- 해결: 사용 가능한 포트로 변경
- 결과: 실제 검증 결과 작성

[오류 로그](logs/troubleshooting-port.txt)

### 사례 2. 바인드 마운트 경로 오류

- 문제: 실제 오류 내용 작성
- 원인 가설: 호스트 경로가 존재하지 않음
- 확인: ls -ld
- 해결: 올바른 디렉터리 경로 지정
- 결과: 실제 검증 결과 작성

[오류 로그](logs/troubleshooting-mount.txt)

## 11. Git 및 GitHub 연동

- Git 기본 브랜치: main
- VS Code에서 GitHub 인증 완료
- GitHub 저장소 연결 및 Push 완료

GitHub 연동 증거:
![VS Code GitHub](evidence/github-vscode.png)

## 12. 최종 결과

실제 검증 결과 요약 및 학습 내용을 작성한다.
