# 시작 가이드

## 개요

이 가이드는 Claude Code CLI 멀티에이전트 오케스트레이션 시스템의 설정 및 사용 방법을 설명합니다.

> 💡 **실제 프로젝트에 적용하려면?**
> 기존 프로젝트 통합, 실제 사용 시나리오, 커스터마이징 방법은 [실제 프로젝트 적용 가이드](practical-guide.md)를 참조하세요.

## 사전 요구사항

- **Claude Code CLI**: 설치 및 인증 완료
- **Git**: 버전 관리용
- **Node.js** 또는 **Python**: 프로젝트에 따라

## 초기 설정

### 1. 프로젝트 클론

```bash
git clone <repository-url>
cd ai-team
```

### 2. Git Hooks 설치

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 3. Claude Code 시작

```bash
claude
```

### 4. 프로젝트 상태 확인

```
/project:status
```

## 시스템 구성

### 에이전트 팀

| 팀 | 에이전트 | 역할 |
|---|---------|------|
| 기획팀 | 리서처, 아키텍트, 디자이너 | 조사, 설계, UI/UX |
| 개발팀 | 백엔드, 프론트엔드, 모바일, DevOps | 구현, 배포 |
| 품질팀 | 코드 리뷰어, 테스터, 보안 감사자 | 검증 |

### 디렉토리 구조

```
.
├── .claude/
│   ├── agents/      # 에이전트 정의
│   ├── commands/    # 슬래시 커맨드
│   └── settings.json
├── state/           # 상태 관리
├── docs/            # 문서
├── scripts/         # 자동화 스크립트
└── CLAUDE.md        # 프로젝트 메모리
```

## 기본 사용법

### 기능 구현

복잡한 기능을 구현할 때 멀티에이전트 오케스트레이션을 사용합니다:

```
/feature:implement 사용자 인증 기능 구현
```

이 명령어는:
1. 리서처가 기술 조사
2. 아키텍트가 시스템 설계
3. 개발자들이 구현
4. 품질팀이 검증

### 기술 리서치

특정 기술에 대해 조사할 때:

```
/feature:research JWT vs Session 인증 비교
```

### 코드 리뷰

변경된 코드를 리뷰할 때:

```
/review:code staged    # 스테이징된 변경사항
/review:code all       # 모든 변경사항
/review:code src/api/  # 특정 디렉토리
```

### 테스트 실행

```
/test:run all          # 모든 테스트
/test:run unit         # 단위 테스트만
/test:coverage         # 커버리지 분석
```

### Git 작업

```
/git:commit            # 자동 커밋
/git:commit feat: 로그인 # 메시지 지정
/git:pr 사용자 인증 기능  # PR 생성
```

### 문서 동기화

```
/docs:sync             # 자동 동기화
/docs:update agents    # 특정 문서 업데이트
```

## 에이전트 직접 호출

특정 에이전트를 직접 호출할 수 있습니다:

```
@researcher JWT 인증 방식 조사해줘
@architect 사용자 서비스 API 설계해줘
@backend-dev 로그인 API 구현해줘
@code-reviewer 변경된 코드 리뷰해줘
```

## 워크플로우 예시

### 새 기능 구현

```
1. /feature:research 기술 조사
2. /feature:design 시스템 설계
3. /feature:implement 구현
4. /review:code 코드 리뷰
5. /test:run 테스트
6. /docs:sync 문서 동기화
7. /git:commit 커밋
8. /git:pr PR 생성
```

### 버그 수정

```
1. 문제 분석
2. @backend-dev 또는 @frontend-dev 수정
3. /review:code 리뷰
4. /test:run 테스트
5. /git:commit 커밋
```

## 상태 관리

### 프로젝트 상태 확인

```
/project:status
```

### 상태 파일 위치

- `state/project-state.json`: 전체 상태
- `state/task-queue.json`: 작업 큐
- `state/agents/`: 에이전트별 상태

## 문제 해결

### 에이전트가 응답하지 않을 때

1. `state/agents/` 디렉토리에서 해당 에이전트 상태 확인
2. 상태를 `idle`로 초기화
3. 다시 호출

### 작업이 차단되었을 때

1. `/project:status`로 차단 원인 확인
2. 의존성 작업 완료 확인
3. 필요시 수동으로 상태 업데이트

### Git Hooks 문제

1. 훅 권한 확인:
```bash
ls -la .git/hooks/
chmod +x .git/hooks/*
```

2. 훅 재설치:
```bash
./scripts/setup.sh
```

## 도움말

Claude Code 내에서:
```
/help
```

## 문서 참조

| 문서 | 설명 |
|------|------|
| [architecture.md](architecture.md) | 시스템 아키텍처 |
| [agents.md](agents.md) | 에이전트 정의 |
| [workflows.md](workflows.md) | 워크플로우 |
| [state-management.md](state-management.md) | 상태 관리 |
| [automation.md](automation.md) | 자동화 기능 |

## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| 2024-01-15 | 초기 문서 작성 | AI Agent |
