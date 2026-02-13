# Sakai React (Next.js) 웹 실행 가이드

> 이 문서는 이 프로젝트를 **웹 기반으로 실행**하기 위해 필요한 기술 요소와 실행 방법(로컬/도커)을 정리한 운영용 가이드입니다.
> https://github.com/primefaces 의 repo 를 private 으로 플젝 진행 후 public 으로 변경한 repo 로 원본 기술 및 repo 는 https://github.com/primefaces 를 참고해 주시기 바랍니다.
---

## 1) 프로젝트 개요

- 프레임워크: **Next.js 13.4.8 (App Router 구조)**
- 런타임: **Node.js 20 권장**
- 패키지 매니저: **npm**
- 기본 서비스 포트: **3000**

`package.json` 기준 주요 스크립트는 아래와 같습니다.

- `npm run dev`: 개발 서버 실행
- `npm run build`: 프로덕션 빌드 생성
- `npm run start`: 빌드 결과 기반 프로덕션 서버 실행
- `npm run lint`: ESLint 검사

---

## 2) 사전 준비 사항

### 필수 소프트웨어

- Node.js 20.x
- npm 9+ (Node 설치 시 포함)

### 선택 소프트웨어

- Docker (컨테이너 실행 시)
- Docker Compose Plugin (`docker compose` 사용 시)

### 환경 변수

현재 코드 기준 필수 `.env` 항목은 강제되지 않지만, 운영 환경에서는 아래 값을 명시적으로 주입하는 것을 권장합니다.

- `NODE_ENV=production`
- `PORT=3000`
- `HOSTNAME=0.0.0.0` (컨테이너 외부 접근이 필요한 경우)

---

## 3) 로컬 실행 방법

### 3-1. 의존성 설치

```bash
npm ci
```

### 3-2. 개발 모드 실행 (핫리로드)

```bash
npm run dev
```

브라우저에서 `http://localhost:3000` 접속.

### 3-3. 운영 모드와 동일하게 실행

```bash
npm run build
npm run start
```

---

## 4) 스크립트 기반 실행 (`sh`)

반복 명령을 단순화하기 위해 `scripts/run-web.sh`를 제공합니다.

### 사용 예시

```bash
# 개발 모드(기본)
./scripts/run-web.sh

# 개발 모드 명시
./scripts/run-web.sh dev

# 운영 빌드 후 실행
./scripts/run-web.sh prod

# 의존성 설치만 수행
./scripts/run-web.sh install
```

### 동작 요약

- `dev`: `npm ci`(node_modules 없을 때만) + `npm run dev`
- `prod`: `npm ci`(node_modules 없을 때만) + `npm run build` + `npm run start`
- `install`: `npm ci`

---

## 5) Docker 기반 실행

멀티 스테이지 빌드를 적용한 `Dockerfile`을 포함합니다.

### 5-1. 이미지 빌드

```bash
docker build -t sakai-react-web:latest .
```

### 5-2. 컨테이너 실행

```bash
docker run --rm -p 3000:3000 --name sakai-react-web sakai-react-web:latest
```

브라우저에서 `http://localhost:3000` 접속.

### 5-3. 쉘 스크립트로 Docker 실행

`./scripts/docker-run.sh`를 사용하면 빌드/실행을 한 번에 처리할 수 있습니다.

```bash
# 이미지 빌드 + 컨테이너 실행
./scripts/docker-run.sh

# 이미지명/컨테이너명/포트 변경
IMAGE_NAME=my-nextjs IMAGE_TAG=v1 CONTAINER_NAME=my-nextjs-web HOST_PORT=3100 ./scripts/docker-run.sh
```

### 5-4. docker compose 실행

```bash
docker compose up --build
```

백그라운드 실행:

```bash
docker compose up --build -d
```

중지:

```bash
docker compose down
```

---

## 6) 운영 관점 권장 사항

- 헬스체크: LB/Ingress에서 `GET /` 또는 별도 health endpoint 확인
- 리소스 제한: CPU/메모리 제한을 compose/k8s 레벨에서 지정
- 로그: 표준 출력 기반 수집(Cloud Logging/ELK 등)
- 보안: 불필요 포트 미노출, 최신 Node 베이스 이미지 유지
- 배포: CI에서 `npm ci -> npm run build -> docker build` 파이프라인 권장

---

## 7) 트러블슈팅

### 포트 충돌 (`EADDRINUSE`)

- 다른 프로세스가 3000 포트를 사용 중입니다.
- 해결: 포트 변경 (`PORT=3100 npm run dev` 또는 Docker `-p 3100:3000`).

### `npm run start` 실행 오류

- 원인: 프로덕션 빌드(`.next`)가 없는 상태.
- 해결: `npm run build` 이후 `npm run start` 실행.

### 컨테이너는 켜졌는데 외부 접속 불가

- `docker run -p 호스트:컨테이너` 포트 매핑 누락 여부 확인
- 방화벽/보안그룹 정책 확인

---

## 8) 빠른 시작 (요약)

### 로컬 개발

```bash
npm ci
npm run dev
```

### Docker 실행

```bash
docker compose up --build
```

