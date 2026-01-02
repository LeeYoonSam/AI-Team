# 실제 프로젝트 적용 가이드

## 개요

이 문서는 멀티에이전트 오케스트레이션 시스템을 실제 프로젝트에 적용하는 방법을 상세히 설명합니다.

---

## 목차

1. [기존 프로젝트에 통합하기](#1-기존-프로젝트에-통합하기)
2. [새 프로젝트에서 시작하기](#2-새-프로젝트에서-시작하기)
3. [실제 사용 시나리오](#3-실제-사용-시나리오)
4. [에이전트 커스터마이징](#4-에이전트-커스터마이징)
5. [베스트 프랙티스](#5-베스트-프랙티스)
6. [문제 해결](#6-문제-해결)

---

## 1. 기존 프로젝트에 통합하기

### 1.1 사전 준비

기존 프로젝트에 시스템을 통합하기 전에 확인할 사항:

```bash
# 프로젝트 루트로 이동
cd /path/to/your-existing-project

# Git 상태 확인
git status

# 현재 브랜치 확인
git branch
```

### 1.2 통합 단계

#### Step 1: 필요한 디렉토리 복사

```bash
# ai-team 저장소에서 필요한 파일들을 복사
cp -r /path/to/ai-team/.claude /path/to/your-project/
cp -r /path/to/ai-team/state /path/to/your-project/
cp -r /path/to/ai-team/scripts /path/to/your-project/
cp -r /path/to/ai-team/templates /path/to/your-project/
```

#### Step 2: CLAUDE.md 수정

프로젝트에 맞게 `CLAUDE.md` 수정:

```markdown
# {프로젝트명}

## 프로젝트 개요
{프로젝트 설명}

## 기술 스택
- Frontend: {React/Vue/Angular 등}
- Backend: {Node.js/Python/Go 등}
- Database: {PostgreSQL/MongoDB 등}
- 기타: {추가 기술}

## 프로젝트 구조
{현재 프로젝트 구조 설명}

## 공통 명령어
{빌드, 테스트, 린트 명령어}

## 코딩 규칙
{프로젝트 코딩 규칙}

## 에이전트 지침
{프로젝트별 특별 지침}
```

#### Step 3: Git Hooks 설치

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

#### Step 4: 설정 파일 조정

`.claude/settings.json`을 프로젝트에 맞게 수정:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Bash(git *)",
      "Bash({프로젝트 패키지 매니저} *)",
      "Grep",
      "Glob"
    ]
  }
}
```

#### Step 5: 커밋

```bash
git add .claude/ state/ scripts/ templates/ CLAUDE.md
git commit -m "chore: 멀티에이전트 오케스트레이션 시스템 통합"
```

### 1.3 프로젝트 유형별 설정

#### React/Next.js 프로젝트

```markdown
# CLAUDE.md 추가 내용

## 공통 명령어
\`\`\`bash
npm run dev          # 개발 서버
npm run build        # 프로덕션 빌드
npm run test         # 테스트 실행
npm run lint         # 린트 검사
\`\`\`

## 컴포넌트 규칙
- 함수형 컴포넌트만 사용
- TypeScript strict 모드
- Tailwind CSS 사용
- 테스트는 Testing Library 사용
```

#### Python/Django 프로젝트

```markdown
# CLAUDE.md 추가 내용

## 공통 명령어
\`\`\`bash
python manage.py runserver  # 개발 서버
python manage.py test       # 테스트 실행
ruff check .               # 린트 검사
mypy .                     # 타입 검사
\`\`\`

## 코딩 규칙
- PEP 8 준수
- Type hints 필수
- Docstring 필수
```

#### Node.js/Express 프로젝트

```markdown
# CLAUDE.md 추가 내용

## 공통 명령어
\`\`\`bash
npm run dev          # 개발 서버
npm run test         # 테스트 실행
npm run lint         # 린트 검사
\`\`\`

## API 규칙
- RESTful 설계 원칙
- 에러 핸들링 미들웨어 사용
- Request validation 필수
```

---

## 2. 새 프로젝트에서 시작하기

### 2.1 프로젝트 초기화

```bash
# 새 프로젝트 디렉토리 생성
mkdir my-new-project
cd my-new-project

# ai-team 시스템 복사
cp -r /path/to/ai-team/* .
cp -r /path/to/ai-team/.* . 2>/dev/null

# 가이드 문서 제거 (선택)
rm claude-code-multi-agent-ochestraion-guide.md

# Git 초기화 및 설정
./scripts/setup.sh
```

### 2.2 프로젝트 스캐폴딩

Claude Code 시작 후:

```
/project:init fullstack
```

그러면 프로젝트 유형에 맞는 구조가 생성됩니다.

### 2.3 기술 스택 설정 예시

#### Full-Stack 웹 앱 (React + Node.js)

```bash
# 프론트엔드
npx create-next-app@latest frontend --typescript --tailwind --app

# 백엔드
mkdir backend
cd backend
npm init -y
npm install express typescript @types/express
```

```
# CLAUDE.md 수정
@architect 프로젝트 아키텍처 설계해줘
```

---

## 3. 실제 사용 시나리오

### 시나리오 1: 사용자 인증 기능 구현

#### 전체 흐름

```
1. 기능 구현 시작
/feature:implement 이메일/비밀번호 기반 사용자 인증 기능

2. 시스템이 자동으로:
   - @researcher: JWT vs Session 비교, 보안 모범 사례 조사
   - @architect: API 설계, DB 스키마 설계
   - @designer: 로그인/회원가입 UI 설계

3. 기획 완료 후 구현:
   - @backend-dev: 인증 API 구현
   - @frontend-dev: 로그인/회원가입 UI 구현

4. 검증:
   - @code-reviewer: 코드 리뷰
   - @tester: 테스트 작성
   - @security-auditor: 보안 점검

5. 완료:
   /docs:sync
   /git:commit
```

#### 단계별 상세

**Step 1: 리서치**
```
@researcher 사용자 인증 구현 방식 조사해줘.
- JWT vs Session 비교
- OAuth 2.0 통합 가능성
- 보안 모범 사례
```

결과: `state/outputs/research-user-auth.md`

**Step 2: 설계**
```
@architect 사용자 인증 시스템 설계해줘.
- API 엔드포인트 설계
- DB 스키마 설계
- 토큰 관리 전략
```

결과:
- `state/outputs/design-user-auth.md`
- `docs/adr/ADR-001-authentication.md`

**Step 3: 백엔드 구현**
```
@backend-dev 설계 문서 기반으로 인증 API 구현해줘.
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/logout
- POST /api/auth/refresh
```

**Step 4: 프론트엔드 구현**
```
@frontend-dev 로그인/회원가입 페이지 구현해줘.
- /login 페이지
- /register 페이지
- 인증 상태 관리
```

**Step 5: 리뷰 및 테스트**
```
/review:code staged
/review:security all
/test:run all
```

**Step 6: 커밋**
```
/git:commit feat: 사용자 인증 기능 구현
```

---

### 시나리오 2: API 엔드포인트 추가

```
# 간단한 엔드포인트 추가
@backend-dev 상품 목록 조회 API 추가해줘.
GET /api/products
- 페이지네이션 지원
- 필터링 (카테고리, 가격)
- 정렬 옵션

# 구현 후 리뷰
/review:code staged

# 테스트 추가
@tester 상품 API 테스트 작성해줘

# 커밋
/git:commit feat: 상품 목록 조회 API 추가
```

---

### 시나리오 3: 버그 수정

```
# 버그 분석
@researcher 로그인 시 세션이 유지되지 않는 문제 분석해줘

# 수정
@backend-dev 세션 쿠키 설정 문제 수정해줘

# 리뷰 및 테스트
/review:code staged
/test:run integration

# 커밋
/git:commit fix: 세션 쿠키 설정 오류 수정
```

---

### 시나리오 4: 리팩토링

```
# 리팩토링 계획
@architect UserService 리팩토링 계획 세워줘.
- 책임 분리
- 테스트 용이성 개선
- 의존성 주입

# 구현
@backend-dev 계획대로 리팩토링 진행해줘

# 검증
/review:code all
/test:run all
/test:coverage

# 커밋
/git:commit refactor: UserService 책임 분리 및 DI 적용
```

---

### 시나리오 5: 새로운 기술 도입

```
# 기술 조사
@researcher Redis 캐싱 도입 가능성 조사해줘.
- 현재 시스템에 적합한지
- 도입 시 장단점
- 구현 방법

# 아키텍처 결정
@architect Redis 캐싱 레이어 설계해줘

# 구현
@backend-dev Redis 캐싱 구현해줘
@devops Redis 인프라 설정해줘

# 검증
/test:run integration
/review:code all
```

---

## 4. 에이전트 커스터마이징

### 4.1 에이전트 수정

`.claude/agents/{agent-name}.md` 파일을 수정하여 에이전트를 커스터마이징합니다.

#### 예시: 백엔드 개발자 에이전트 수정

```markdown
---
name: backend-dev
description: API 구현, 데이터베이스 작업, 서버 로직 전문가.
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
permissionMode: default
---

# 백엔드 개발자 에이전트

## 프로젝트별 설정

### 기술 스택
- 언어: TypeScript
- 프레임워크: NestJS
- ORM: Prisma
- DB: PostgreSQL

### 코딩 규칙
- 모든 서비스에 interface 정의
- DTO 사용 필수
- 에러는 커스텀 Exception 사용
- 로깅은 NestJS Logger 사용

### 파일 구조
\`\`\`
src/
├── modules/
│   └── {module}/
│       ├── {module}.controller.ts
│       ├── {module}.service.ts
│       ├── {module}.module.ts
│       ├── dto/
│       └── entities/
└── common/
    ├── filters/
    └── interceptors/
\`\`\`
```

### 4.2 새 에이전트 추가

프로젝트에 특화된 새 에이전트를 추가할 수 있습니다.

#### 예시: 데이터베이스 전문가 에이전트

```markdown
---
name: db-specialist
description: 데이터베이스 설계, 쿼리 최적화, 마이그레이션 전문가.
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
permissionMode: default
---

# 데이터베이스 전문가 에이전트

당신은 데이터베이스 설계와 최적화를 전문으로 하는 DBA입니다.

## 핵심 책임
1. 스키마 설계 및 정규화
2. 쿼리 성능 최적화
3. 인덱스 전략
4. 마이그레이션 관리

## 사용 DB
- PostgreSQL
- Redis (캐시)

## 도구
- Prisma (ORM)
- pgAdmin (관리)
```

### 4.3 슬래시 커맨드 추가

프로젝트에 특화된 커맨드를 추가합니다.

#### 예시: 배포 커맨드

```markdown
---
description: 스테이징 또는 프로덕션 환경에 배포합니다.
argument-hint: [staging|production]
allowed-tools: Bash, Read
model: haiku
---

# 배포

## 환경
$ARGUMENTS

## 배포 프로세스

### staging
1. 테스트 실행
2. 빌드
3. staging 서버에 배포

### production
1. 테스트 실행
2. 빌드
3. 배포 승인 확인
4. production 서버에 배포
5. 헬스 체크
```

---

## 5. 베스트 프랙티스

### 5.1 효율적인 에이전트 사용

#### DO ✅

```
# 구체적이고 명확한 요청
@backend-dev POST /api/users 엔드포인트 구현해줘.
요청 바디: { name, email, password }
응답: { id, name, email, createdAt }
유효성 검사 포함

# 컨텍스트 제공
@frontend-dev 기존 Button 컴포넌트 스타일을 따르는
IconButton 컴포넌트 만들어줘.
src/components/Button.tsx 참고
```

#### DON'T ❌

```
# 모호한 요청
@backend-dev API 만들어줘

# 컨텍스트 없는 요청
@frontend-dev 버튼 만들어줘
```

### 5.2 작업 단위 분리

#### 좋은 예 ✅

```
# 작은 단위로 나누어 진행
1. @architect 사용자 API 설계
2. @backend-dev 사용자 CRUD 구현
3. @tester 사용자 API 테스트 작성
4. /review:code staged
5. /git:commit feat: 사용자 CRUD API 구현

# 다음 기능
1. @architect 인증 API 설계
2. ...
```

#### 나쁜 예 ❌

```
# 한 번에 너무 많이
/feature:implement 사용자 관리, 인증, 권한,
프로필, 설정, 알림 기능 전부 구현
```

### 5.3 리뷰 및 테스트 활용

```
# 모든 기능 구현 후 반드시
/review:code staged    # 코드 리뷰
/review:security all   # 보안 리뷰
/test:run all          # 테스트 실행
/test:coverage         # 커버리지 확인
```

### 5.4 문서 동기화

```
# 주요 변경 후
/docs:sync

# 아키텍처 변경 시
@architect ADR 작성해줘
```

### 5.5 커밋 전략

```
# 작은 단위로 자주 커밋
/git:commit feat: 사용자 모델 추가
/git:commit feat: 사용자 서비스 구현
/git:commit feat: 사용자 컨트롤러 구현
/git:commit test: 사용자 API 테스트 추가

# 의미 있는 단위로 PR
/git:pr 사용자 CRUD API 구현
```

---

## 6. 문제 해결

### 6.1 일반적인 문제

#### 에이전트가 컨텍스트를 잃어버릴 때

```
# 명시적으로 파일 참조
@backend-dev src/services/user.service.ts 파일의
findById 메서드를 수정해줘. 캐싱 로직 추가.

# 이전 작업 결과 참조
@frontend-dev state/outputs/design-login.md 설계 문서를
참고해서 로그인 페이지 구현해줘.
```

#### 에이전트가 잘못된 파일을 수정할 때

```
# CLAUDE.md에 명확한 구조 정의
## 프로젝트 구조
- src/api/: 백엔드 API 코드
- src/web/: 프론트엔드 코드
- src/mobile/: 모바일 앱 코드

## 에이전트 지침
- @backend-dev: src/api/ 디렉토리만 수정
- @frontend-dev: src/web/ 디렉토리만 수정
```

#### 작업이 너무 오래 걸릴 때

```
# 작업을 더 작은 단위로 분할
# 대신:
/feature:implement 전체 이커머스 시스템

# 이렇게:
/feature:implement 상품 목록 기능
/feature:implement 장바구니 기능
/feature:implement 결제 기능
```

### 6.2 상태 초기화

```
# 프로젝트 상태 초기화
cat > state/project-state.json << 'EOF'
{
  "projectId": "my-project",
  "status": "initialized",
  "currentPhase": null,
  "agents": {},
  "completedTasks": [],
  "pendingTasks": []
}
EOF

# 작업 큐 초기화
cat > state/task-queue.json << 'EOF'
{
  "queue": []
}
EOF
```

### 6.3 Git Hooks 문제

```bash
# 훅 비활성화 (임시)
git config core.hooksPath /dev/null

# 훅 재활성화
git config core.hooksPath .git/hooks

# 훅 재설치
./scripts/setup.sh
```

---

## 체크리스트

### 프로젝트 시작 전

- [ ] CLAUDE.md 프로젝트에 맞게 수정
- [ ] .claude/settings.json 권한 설정 확인
- [ ] Git Hooks 설치 (`./scripts/setup.sh`)
- [ ] 에이전트 정의 검토 및 필요시 수정

### 기능 개발 시

- [ ] 구체적인 요청 작성
- [ ] 적절한 에이전트 선택
- [ ] 작은 단위로 작업 분할
- [ ] 각 단계 후 리뷰
- [ ] 테스트 작성

### 커밋/PR 전

- [ ] `/review:code staged` 실행
- [ ] `/test:run all` 실행
- [ ] `/docs:sync` 실행 (필요시)
- [ ] 커밋 메시지 규칙 준수

---

## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| 2024-01-15 | 초기 문서 작성 | AI Agent |
