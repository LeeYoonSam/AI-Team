---
description: 현재 프로젝트 상태와 에이전트 활동을 확인합니다.
allowed-tools: Read, Glob, Bash
model: haiku
---

# 프로젝트 상태 확인

## 확인 항목

### 1. Git 상태
```bash
git status --short
git log --oneline -5
git branch -a
```

### 2. 프로젝트 상태
`state/project-state.json` 파일 확인 (있는 경우)

### 3. 에이전트 상태
`state/agents/` 디렉토리의 모든 JSON 파일 확인

### 4. 대기 중인 작업
`state/task-queue.json` 파일 확인 (있는 경우)

### 5. 최근 산출물
`state/outputs/` 디렉토리의 최근 파일 목록

## 출력 형식

```markdown
# 프로젝트 상태 리포트

## 개요
- 프로젝트명: {이름}
- 현재 단계: {phase}
- 활성 작업: {task}
- 마지막 업데이트: {timestamp}

## 에이전트 상태
| 에이전트 | 상태 | 마지막 활동 | 현재 작업 |
|---------|------|------------|----------|
| backend-dev | in_progress | 10분 전 | API 구현 |
| frontend-dev | blocked | 30분 전 | API 대기 |

## 작업 큐
| 우선순위 | 작업 | 담당 | 상태 | 의존성 |
|---------|------|------|------|--------|
| 1 | API 구현 | backend-dev | in_progress | - |
| 2 | UI 구현 | frontend-dev | blocked | API 구현 |

## Git 상태
- 브랜치: {branch}
- 변경된 파일: {count}
- 최근 커밋: {message}

## 최근 산출물
- state/outputs/research-auth.md (1시간 전)
- state/outputs/api-spec.json (30분 전)

## 권장 조치
{다음 단계 제안}
```

## 상태 없을 경우

프로젝트 상태 파일이 없으면:
- `/project:init` 실행 권장
- 기본 구조 확인
