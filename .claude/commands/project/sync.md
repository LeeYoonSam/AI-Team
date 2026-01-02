---
description: 코드 변경에 따라 관련 문서를 동기화합니다.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
---

# 프로젝트 문서 동기화

## 변경 감지

### 1. 최근 변경 확인
```bash
git diff --name-only HEAD~1
git diff --name-only --staged
```

### 2. 변경 유형 분류

| 변경 경로 | 관련 문서 |
|----------|----------|
| `src/api/` | `docs/architecture.md`, API 문서 |
| `.claude/agents/` | `docs/agents.md` |
| `.claude/commands/` | `docs/workflows.md` |
| `state/` | `docs/state-management.md` |
| `scripts/` | `docs/automation.md` |

## 문서 업데이트 프로세스

### 1. 에이전트 변경 시
`.claude/agents/` 파일이 변경되면:
- `docs/agents.md` 업데이트
- 에이전트 목록 및 역할 테이블 갱신
- 변경 이력 추가

### 2. 워크플로우 변경 시
`.claude/commands/` 파일이 변경되면:
- `docs/workflows.md` 업데이트
- 슬래시 커맨드 목록 갱신
- 사용법 업데이트

### 3. 아키텍처 변경 시
주요 구조 변경이 감지되면:
- `docs/architecture.md` 업데이트
- 다이어그램 갱신
- 새 컴포넌트 추가

### 4. API 변경 시
API 관련 파일 변경 시:
- API 문서 업데이트
- 엔드포인트 목록 갱신

## 동기화 규칙

### 변경 이력 형식
```markdown
## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| {오늘 날짜} | {변경 요약} | AI Agent |
```

### 자동 커밋
문서 업데이트 후:
```bash
git add docs/
git commit -m "docs: 문서 자동 동기화"
```

## 출력

동기화 완료 후:
- 업데이트된 문서 목록
- 각 문서의 변경 요약
- 커밋 정보 (자동 커밋 시)
