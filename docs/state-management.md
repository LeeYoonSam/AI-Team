# 상태 관리 및 통신

## 개요

에이전트 간 통신은 파일 시스템 기반으로 이루어집니다. 이 문서는 상태 관리 시스템의 구조와 사용법을 설명합니다.

## 디렉토리 구조

```
state/
├── project-state.json     # 전체 프로젝트 상태
├── task-queue.json        # 작업 대기열
├── agents/                # 에이전트별 상태
│   ├── backend-dev.json
│   ├── frontend-dev.json
│   └── ...
├── checkpoints/           # 체크포인트 저장소
│   └── checkpoint-{timestamp}.json
└── outputs/               # 에이전트 산출물
    ├── research-{topic}.md
    ├── design-{feature}.md
    └── ...
```

## 상태 파일

### project-state.json

전체 프로젝트 상태를 관리합니다.

```json
{
  "projectId": "ai-team",
  "currentPhase": "implementation",
  "lastUpdated": "2024-01-15T10:30:00Z",
  "activeTask": {
    "id": "feature-user-auth",
    "description": "사용자 인증 기능 구현",
    "startedAt": "2024-01-15T09:00:00Z",
    "phase": "implementation"
  },
  "agents": {
    "researcher": {
      "status": "completed",
      "lastActivity": "2024-01-15T09:30:00Z"
    },
    "architect": {
      "status": "completed",
      "lastActivity": "2024-01-15T09:45:00Z"
    },
    "backend-dev": {
      "status": "in_progress",
      "lastActivity": "2024-01-15T10:30:00Z"
    },
    "frontend-dev": {
      "status": "blocked",
      "blockedBy": "API 계약 대기"
    }
  },
  "completedTasks": [
    "research-auth",
    "design-auth-api"
  ],
  "pendingTasks": [
    "impl-auth-backend",
    "impl-auth-frontend",
    "test-auth",
    "review-auth"
  ]
}
```

### task-queue.json

작업 대기열을 관리합니다.

```json
{
  "queue": [
    {
      "id": "impl-auth-backend",
      "agent": "backend-dev",
      "status": "in_progress",
      "priority": 1,
      "dependencies": ["design-auth-api"],
      "createdAt": "2024-01-15T09:45:00Z",
      "startedAt": "2024-01-15T10:00:00Z"
    },
    {
      "id": "impl-auth-frontend",
      "agent": "frontend-dev",
      "status": "blocked",
      "priority": 2,
      "dependencies": ["impl-auth-backend"],
      "blockedReason": "API 엔드포인트 구현 대기"
    }
  ]
}
```

### agents/{agent-name}.json

개별 에이전트의 상태를 관리합니다.

```json
{
  "agentId": "backend-dev",
  "currentTask": "impl-auth-backend",
  "status": "in_progress",
  "progress": 60,
  "lastOutput": "state/outputs/auth-api-progress.md",
  "messages": [
    {
      "timestamp": "2024-01-15T10:30:00Z",
      "type": "progress",
      "content": "JWT 서비스 구현 완료, 컨트롤러 작업 중"
    }
  ],
  "metrics": {
    "filesCreated": 3,
    "filesModified": 2,
    "testsAdded": 5
  }
}
```

## 상태 값

### 작업 상태

| 상태 | 설명 |
|------|------|
| `pending` | 대기 중 (아직 시작되지 않음) |
| `in_progress` | 진행 중 |
| `completed` | 완료 |
| `failed` | 실패 |
| `blocked` | 차단됨 (의존성 대기) |

### 에이전트 상태

| 상태 | 설명 |
|------|------|
| `idle` | 유휴 상태 |
| `working` | 작업 중 |
| `waiting` | 대기 중 (입력 필요) |
| `completed` | 작업 완료 |
| `failed` | 작업 실패 |
| `blocked` | 차단됨 |

## 체크포인트

마일스톤마다 체크포인트를 저장하여 실패 시 복구할 수 있습니다.

### 체크포인트 파일 형식

```json
{
  "checkpointId": "checkpoint-20240115-100000",
  "timestamp": "2024-01-15T10:00:00Z",
  "description": "사용자 인증 설계 완료",
  "state": {
    "projectState": { ... },
    "taskQueue": { ... },
    "agents": { ... }
  }
}
```

### 체크포인트 저장 시점

- 각 Phase 완료 시
- 주요 마일스톤 달성 시
- 복잡한 작업 중간 지점

## 복구 절차

### 1. 마지막 체크포인트 확인
```bash
ls -la state/checkpoints/
```

### 2. 체크포인트 내용 확인
```bash
cat state/checkpoints/checkpoint-{timestamp}.json
```

### 3. 상태 복원
체크포인트의 상태를 현재 상태 파일에 복사

### 4. 작업 재개
실패한 작업부터 재시작

## 에이전트 간 통신 프로토콜

### 메시지 형식

```json
{
  "messageId": "msg-001",
  "fromAgent": "researcher",
  "toAgent": "backend-dev",
  "type": "task_assignment",
  "payload": {
    "taskId": "impl-user-auth",
    "content": {
      "research_summary": "JWT with refresh tokens 권장",
      "patterns_found": ["apps/api/src/auth/jwt.service.ts"],
      "recommendations": [
        "기존 JwtService 패턴 사용",
        "인증 엔드포인트에 rate limiting 추가"
      ],
      "files_to_modify": [
        "apps/api/src/auth/auth.controller.ts",
        "apps/api/src/auth/auth.service.ts"
      ]
    },
    "priority": "high"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### 메시지 타입

| 타입 | 설명 |
|------|------|
| `task_assignment` | 작업 할당 |
| `status_update` | 상태 업데이트 |
| `feedback` | 피드백 |
| `completion` | 완료 알림 |
| `error` | 오류 알림 |

## 산출물 관리

### 산출물 디렉토리

`state/outputs/` 디렉토리에 에이전트 산출물 저장

### 파일 명명 규칙

```
{type}-{topic}-{timestamp}.{ext}

예:
- research-user-auth.md
- design-api-spec.yaml
- review-20240115.md
- test-coverage.json
```

### 산출물 타입

| 타입 | 에이전트 | 형식 |
|------|---------|------|
| `research-*` | 리서처 | Markdown |
| `design-*` | 아키텍트, 디자이너 | Markdown, YAML |
| `review-*` | 코드 리뷰어 | Markdown |
| `security-*` | 보안 감사자 | Markdown |
| `test-*` | 테스터 | Markdown, JSON |

## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| 2024-01-15 | 초기 문서 작성 | AI Agent |
