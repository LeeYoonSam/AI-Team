# 에이전트 정의 및 역할

## 개요

이 시스템은 10명의 전문가 에이전트 + 1명의 매니저로 구성된 AI 개발 팀입니다.

## 에이전트 요약

| 에이전트 | 모델 | 역할 | 파일 |
|---------|------|------|------|
| 매니저 | Opus | 작업 분배, 진행 관리 | `manager.md` |
| 리서처 | Sonnet | 기술 조사, 정보 수집 | `researcher.md` |
| 아키텍트 | Opus | 시스템 설계, API 설계 | `architect.md` |
| 디자이너 | Sonnet | UI/UX 설계 | `designer.md` |
| 백엔드 개발자 | Sonnet | API 구현, DB 작업 | `backend-dev.md` |
| 프론트엔드 개발자 | Sonnet | UI 컴포넌트, 상태 관리 | `frontend-dev.md` |
| 모바일 개발자 | Sonnet | 모바일 앱 개발 | `mobile-dev.md` |
| 코드 리뷰어 | Sonnet | 코드 품질 검토 | `code-reviewer.md` |
| 테스터 | Haiku | 테스트 작성/실행 | `tester.md` |
| 보안 감사자 | Sonnet | 보안 취약점 분석 | `security-auditor.md` |
| DevOps | Sonnet | CI/CD, 배포 | `devops.md` |

## 상세 정보

### 매니저 에이전트 (Team Manager)

**파일**: `.claude/agents/manager.md`

| 항목 | 내용 |
|------|------|
| 모델 | Opus 4 |
| 역할 | 작업 분해, 에이전트 할당, 진행 관리, 결과 통합 |
| 도구 | Read, Write, Edit, Glob, Grep, Bash |
| 호출 시점 | 복잡한 작업, 여러 에이전트 협업 필요 시 |

**주요 책임**:
- 사용자 요청을 작업 단위로 분해
- 적절한 에이전트에게 작업 할당
- 진행 상황 모니터링
- 결과물 통합 및 검증

---

### 기획팀

#### 리서처 (Researcher)

**파일**: `.claude/agents/researcher.md`

| 항목 | 내용 |
|------|------|
| 모델 | Sonnet |
| 역할 | 기술 조사, 패턴 분석, 정보 수집 |
| 도구 | Read, Grep, Glob, WebSearch, WebFetch, Bash |
| 산출물 | 리서치 리포트, 권장사항 |

#### 아키텍트 (Architect)

**파일**: `.claude/agents/architect.md`

| 항목 | 내용 |
|------|------|
| 모델 | Opus |
| 역할 | 시스템 설계, API 설계, 기술 결정 |
| 도구 | Read, Write, Edit, Grep, Glob |
| 산출물 | ADR, API 명세, 시스템 다이어그램 |

#### 디자이너 (Designer)

**파일**: `.claude/agents/designer.md`

| 항목 | 내용 |
|------|------|
| 모델 | Sonnet |
| 역할 | UI/UX 설계, 디자인 시스템 관리 |
| 도구 | Read, Write, Grep, Glob |
| 산출물 | 컴포넌트 명세, 사용자 흐름 |

---

### 개발팀

#### 백엔드 개발자 (Backend Developer)

**파일**: `.claude/agents/backend-dev.md`

| 항목 | 내용 |
|------|------|
| 모델 | Sonnet |
| 역할 | API 구현, 데이터베이스 작업, 서버 로직 |
| 도구 | Read, Write, Edit, Bash, Grep, Glob |
| 산출물 | 소스 코드, 테스트 코드, 마이그레이션 |

#### 프론트엔드 개발자 (Frontend Developer)

**파일**: `.claude/agents/frontend-dev.md`

| 항목 | 내용 |
|------|------|
| 모델 | Sonnet |
| 역할 | UI 컴포넌트, 상태 관리, 사용자 인터랙션 |
| 도구 | Read, Write, Edit, Bash, Glob, Grep |
| 산출물 | 컴포넌트, 페이지, 훅, 테스트 |

#### 모바일 개발자 (Mobile Developer)

**파일**: `.claude/agents/mobile-dev.md`

| 항목 | 내용 |
|------|------|
| 모델 | Sonnet |
| 역할 | iOS/Android/React Native 개발 |
| 도구 | Read, Write, Edit, Bash, Glob, Grep |
| 산출물 | 모바일 앱 코드 |

#### DevOps 엔지니어 (DevOps Engineer)

**파일**: `.claude/agents/devops.md`

| 항목 | 내용 |
|------|------|
| 모델 | Sonnet |
| 역할 | CI/CD, 인프라, 배포 자동화 |
| 도구 | Bash, Read, Write, Edit, Glob, Grep |
| 산출물 | 워크플로우, Dockerfile, 인프라 코드 |

---

### 품질팀

#### 코드 리뷰어 (Code Reviewer)

**파일**: `.claude/agents/code-reviewer.md`

| 항목 | 내용 |
|------|------|
| 모델 | Sonnet |
| 역할 | 코드 품질, 보안, 유지보수성 리뷰 |
| 도구 | Read, Grep, Glob, Bash |
| 산출물 | 리뷰 리포트 |

#### 테스터 (Tester)

**파일**: `.claude/agents/tester.md`

| 항목 | 내용 |
|------|------|
| 모델 | Haiku |
| 역할 | 테스트 작성, 실행, 커버리지 분석 |
| 도구 | Read, Write, Edit, Bash, Glob, Grep |
| 산출물 | 테스트 코드, 테스트 리포트 |

#### 보안 감사자 (Security Auditor)

**파일**: `.claude/agents/security-auditor.md`

| 항목 | 내용 |
|------|------|
| 모델 | Sonnet |
| 역할 | 보안 취약점 분석, OWASP 점검 |
| 도구 | Read, Grep, Glob, Bash |
| 산출물 | 보안 감사 리포트 |

---

## 에이전트 호출 방법

### 자동 호출
에이전트의 `description` 필드에 명시된 트리거 조건에 따라 자동 호출됩니다.

예시:
- 코드 변경 후 → `code-reviewer` 자동 호출
- 기술 결정 전 → `researcher` 자동 호출

### 명시적 호출
```
@researcher 사용자 인증 기술 조사해줘
@backend-dev 로그인 API 구현해줘
@code-reviewer 변경된 코드 리뷰해줘
```

### 오케스트레이션
```
/feature:implement 사용자 인증 기능 구현
```
매니저 에이전트가 자동으로 필요한 에이전트들을 조율합니다.

## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| 2024-01-15 | 초기 문서 작성 | AI Agent |
