---
description: 코드 변경에 따라 관련 문서를 자동으로 동기화합니다.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
---

# 문서 자동 동기화

## 변경 감지

### 1. 최근 변경 확인
```bash
git diff --name-only HEAD~1
git diff --name-only --staged
```

### 2. 변경 유형 분류

| 변경 경로 | 업데이트 문서 |
|----------|--------------|
| `.claude/agents/` | `docs/agents.md` |
| `.claude/commands/` | `docs/workflows.md` |
| `src/api/` | `docs/architecture.md` |
| `state/` | `docs/state-management.md` |
| `scripts/` | `docs/automation.md` |

## 문서 업데이트 프로세스

### 1. 에이전트 문서 (`docs/agents.md`)

`.claude/agents/` 변경 시:
- 에이전트 목록 테이블 업데이트
- 새 에이전트 추가 시 역할 설명 추가
- 삭제된 에이전트 제거

### 2. 워크플로우 문서 (`docs/workflows.md`)

`.claude/commands/` 변경 시:
- 슬래시 커맨드 목록 업데이트
- 새 커맨드 사용법 추가
- 워크플로우 다이어그램 갱신

### 3. 아키텍처 문서 (`docs/architecture.md`)

주요 구조 변경 시:
- 시스템 다이어그램 업데이트
- 컴포넌트 설명 추가/수정
- 기술 스택 정보 갱신

### 4. 시작 가이드 (`docs/getting-started.md`)

설정 변경 시:
- 설치 단계 업데이트
- 설정 파일 예시 갱신
- 사용법 업데이트

## 변경 이력 추가

각 문서 하단에 변경 이력 섹션 업데이트:

```markdown
## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| {오늘} | {변경 요약} | AI Agent |
```

## 자동 커밋 (선택)

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
