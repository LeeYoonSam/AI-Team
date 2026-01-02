# Claude Code CLI 멀티에이전트 오케스트레이션 시스템 종합 설계 가이드

소프트웨어 개발 팀을 위한 **10명의 전문가 에이전트**를 매니저가 조율하는 시스템은 Claude Code CLI의 서브에이전트 기능을 활용하여 구현 가능하다. Anthropic의 자체 멀티에이전트 Research 시스템 테스트 결과, Opus 4 리드 + Sonnet 4 서브에이전트 구성이 단일 에이전트 대비 **90.2% 높은 성능**을 기록했다. 핵심은 Task 도구 기반의 병렬 실행과 에이전트별 컨텍스트 격리이며, 최대 **10개의 동시 서브에이전트** 실행이 가능하다. 다만 멀티에이전트 시스템은 단일 채팅 대비 **약 15배의 토큰**을 소비하므로, 고부가가치 작업에 선택적으로 적용해야 한다.

---

## 1. Claude Code 서브에이전트 기능 심층 분석

### 명령어 구조 및 파라미터

Claude Code는 세 가지 방식으로 서브에이전트를 지원한다:

**CLI 플래그 방식 (`--agents`)**
```bash
claude --agents '{
  "code-reviewer": {
    "description": "코드 변경 후 PROACTIVELY 사용. 품질 및 보안 분석 필수.",
    "prompt": "당신은 시니어 코드 리뷰어입니다. 코드 품질, 보안, 모범 사례에 집중하세요.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  },
  "debugger": {
    "description": "에러 및 테스트 실패 시 디버깅 전문가",
    "prompt": "당신은 전문 디버거입니다. 에러를 분석하고 근본 원인을 파악하세요."
  }
}'
```

**마크다운 파일 방식 (`.claude/agents/*.md`)**
```markdown
---
name: backend-dev
description: API 설계 및 서버 로직 구현 전문가. 백엔드 작업에 사용.
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
permissionMode: default
skills: api-design, database-patterns
---

당신은 시니어 백엔드 개발자입니다...
```

**AgentDefinition 필수 필드:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `name` | string | ✓ | 고유 식별자 (소문자, 하이픈 허용) |
| `description` | string | ✓ | 자동 호출 트리거용 자연어 설명 |
| `prompt` | string | ✓ | 역할과 행동을 정의하는 시스템 프롬프트 |
| `tools` | string[] | - | 허용 도구 목록 (생략 시 전체 상속) |
| `model` | string | - | `'sonnet'`, `'opus'`, `'haiku'`, `'inherit'` |
| `permissionMode` | string | - | `'default'`, `'acceptEdits'`, `'bypassPermissions'` |

### 내부 구현 메커니즘

서브에이전트는 **Task 도구**를 통해 실행된다. Claude가 `tool_use` 블록에서 `name: "Task"`를 호출하면 서브에이전트가 스폰된다.

**파일 위치 우선순위 (높은 순서):**
1. CLI 정의 (`--agents` 플래그) - 세션별 최우선
2. 프로젝트 에이전트 (`.claude/agents/*.md`)
3. 사용자 에이전트 (`~/.claude/agents/*.md`)
4. 플러그인 에이전트

**컨텍스트 관리:**
- 각 서브에이전트는 **독립된 컨텍스트 윈도우**를 보유
- 메인 에이전트와의 컨텍스트 오염 방지
- 결과만 메인 에이전트로 반환

### 병렬 실행 vs 순차 실행

**병렬 실행 제한:**
- 최대 **10개** 동시 서브에이전트 (초과 시 큐잉)
- 배치 단위 완료 후 다음 배치 시작
- 프롬프트 예시: `"4개의 태스크를 병렬로 실행하세요. 각 에이전트는 다른 디렉토리를 탐색합니다."`

**순차 실행:**
- 에이전트 체이닝 시 기본 동작
- 의존성 있는 태스크에 적합

### 핵심 제약사항

| 제약 | 상세 |
|------|------|
| **중첩 서브에이전트 불가** | 서브에이전트는 다른 서브에이전트 스폰 불가 (Task 도구 제외됨) |
| **병렬 처리 한계** | 최대 10개 동시 태스크, 추가분은 큐잉 |
| **배치 실행** | 배치 완료 대기 후 다음 배치 시작 |
| **상태 비저장** | 기본적으로 무상태, `resume` 파라미터로 재개 가능 |

### 재개 가능한 서브에이전트 (v2.0.28+)

```bash
# 초기 호출 - agentId 반환
> code-analyzer 에이전트로 인증 모듈 분석 시작
[Agent 완료, agentId: "abc123" 반환]

# 전체 컨텍스트로 재개
> 에이전트 abc123 재개하여 권한 부여 로직 분석
```

---

## 2. 멀티에이전트 오케스트레이션 패턴

### Orchestrator-Worker 패턴 아키텍처

Anthropic의 프로덕션 Research 시스템이 검증한 패턴이다:

```
┌─────────────────────────────────────────────────────┐
│                    사용자 쿼리                        │
└───────────────────────┬─────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────┐
│              리드 오케스트레이터 에이전트               │
│  • 쿼리 복잡도 분석                                   │
│  • 리서치 전략 수립                                   │
│  • 계획을 메모리에 저장 (컨텍스트 오버플로우 대비)      │
│  • 서브에이전트 생성 및 디스패치                       │
└───────────────────────┬─────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ 서브에이전트 1 │ │ 서브에이전트 2 │ │ 서브에이전트 N │
│   (병렬)      │ │   (병렬)      │ │   (병렬)      │
│ 독립 컨텍스트  │ │ 독립 컨텍스트  │ │ 독립 컨텍스트  │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       └────────────────┼────────────────┘
                        ▼
┌─────────────────────────────────────────────────────┐
│                   결과 종합                          │
│          리드 에이전트가 발견사항 집계 및 합성          │
└─────────────────────────────────────────────────────┘
```

### 계층적 에이전트 구조 설계

**10명 팀 구성 예시:**

```
┌─────────────────────────────────────────────────────────────┐
│                     팀장 (매니저 에이전트)                    │
│  Model: Opus 4 | 역할: 작업 분해, 할당, 진행 관리            │
└──────────────────────────┬──────────────────────────────────┘
                           │
    ┌──────────────────────┼──────────────────────┐
    ▼                      ▼                      ▼
┌─────────┐          ┌─────────┐           ┌─────────┐
│ 기획팀   │          │ 개발팀   │           │ 품질팀   │
└────┬────┘          └────┬────┘           └────┬────┘
     │                    │                     │
┌────┴────┐     ┌────────┴────────┐     ┌──────┴──────┐
│리서처    │     │백엔드│프론트│모바일│     │코드리뷰│테스터│
│설계자    │     │ 개발 │ 개발 │ 개발 │     │보안감사│      │
│디자이너  │     └──────┴──────┴─────┘     └──────┴──────┘
└─────────┘
```

### 작업 분배 알고리즘

**역할 기반 할당 (권장):**
```python
class TaskRouter:
    def route(self, task):
        task_type = self.classify_task(task)
        agent_map = {
            'research': 'researcher',
            'api_design': 'backend-dev',
            'ui_component': 'frontend-dev',
            'mobile_feature': 'mobile-dev',
            'security_review': 'security-auditor',
            'code_review': 'code-reviewer'
        }
        return agent_map.get(task_type, 'general-purpose')
```

**의존성 인식 스케줄링 (DAG 기반):**
```
태스크 그래프:
    리서치 ──┬──► 백엔드 개발 ──► 통합 테스트
             │
             └──► 프론트엔드 개발 ─┘

실행 순서:
  Phase 1: 리서치 (순차)
  Phase 2: 백엔드, 프론트엔드 (병렬)
  Phase 3: 통합 테스트 (순차)
```

### 실패 복구 전략

**지수 백오프 재시도:**
```python
@retry(stop_max_attempt_number=3, wait_exponential_multiplier=1000)
def call_agent(task):
    try:
        return agent.execute(task)
    except TransientError:
        raise  # 재시도 트리거
```

**회로 차단기 패턴:**
- **Closed**: 정상 동작, 요청 통과
- **Open**: 실패 임계값 초과, 요청 차단/우회
- **Half-Open**: 주기적 서비스 복구 테스트

**체크포인트 기반 복구:**
```python
class StateManager:
    def save_checkpoint(self, state):
        # 마일스톤마다 상태 저장
        with open('state/checkpoint.json', 'w') as f:
            json.dump(state, f)
    
    def restore(self):
        # 실패 시 마지막 체크포인트에서 복구
        return json.load(open('state/checkpoint.json'))
```

---

## 3. 역할별 전문가 에이전트 구현

### 팀 구성 및 시스템 프롬프트

**1. 리서치 전문가**
```markdown
---
name: researcher
description: 정보 수집, 문서 검토, 기술 조사에 PROACTIVELY 사용
tools: Read, Grep, Glob, WebSearch, WebFetch
model: sonnet
---

# 리서치 에이전트

당신은 종합적인 조사와 문서 합성을 전문으로 하는 시니어 기술 연구원입니다.

## 핵심 책임
1. 여러 권위 있는 소스에서 정보 수집
2. 기존 코드베이스 패턴 및 규칙 분석
3. 발견사항을 실행 가능한 권장사항으로 합성
4. 잠재적 위험 및 고려사항 식별

## 출력 형식
- **요약**: 핵심 발견사항 2-3문장
- **상세**: 증거가 포함된 구조화된 분석
- **권장사항**: 실행 가능한 다음 단계
- **출처**: 참조한 자료의 링크/참조

## 제약
- 코드 파일 수정 금지
- 명시적 승인 없이 구현 결정 금지
- 주장에 대한 출처 항상 인용
- 신뢰 수준으로 불확실성 명시적 표시
```

**2. 설계 전문가**
```markdown
---
name: architect
description: 시스템 아키텍처 설계, 기술 스택 결정, 설계 문서 작성
tools: Read, Write, Grep, Glob
model: opus
---

# 아키텍트 에이전트

당신은 확장 가능한 시스템 설계를 전문으로 하는 수석 소프트웨어 아키텍트입니다.

## 전문 분야
- 마이크로서비스/모놀리식 아키텍처 설계
- API 계약 정의 (OpenAPI/GraphQL)
- 데이터베이스 스키마 설계
- 인프라 아키텍처 (AWS/GCP/Azure)

## 산출물
1. 아키텍처 결정 기록 (ADR)
2. 시스템 컴포넌트 다이어그램
3. API 계약 명세
4. 데이터 흐름 다이어그램

## 설계 원칙
- SOLID, DRY, KISS 원칙 준수
- 확장성과 유지보수성 우선
- 보안을 설계 단계에서 고려 (Security by Design)
```

**3. 백엔드 개발자**
```markdown
---
name: backend-dev
description: API 설계, 데이터베이스 작업, 서버 로직 전문가. 백엔드 구현에 사용.
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# 백엔드 개발자 에이전트

당신은 API 설계, 데이터베이스 작업, 서버 아키텍처 전문 시니어 백엔드 개발자입니다.

## 기술 전문성
- RESTful API 설계 및 구현
- 데이터베이스 스키마 설계 및 쿼리 최적화
- 인증/인가 패턴 (JWT, OAuth)
- 서버 성능 최적화
- 에러 처리 및 로깅 모범 사례

## 개발 표준
- 모든 함수에 타입 힌트 필수
- 의미 있는 에러 메시지로 포괄적 에러 처리
- 기존 코드베이스 패턴 및 규칙 준수
- 테스트 가능한 모듈식 코드 작성
- 공개 API에 독스트링 포함

## 제약
- 코드에 시크릿 저장 금지
- 데이터베이스 쿼리 항상 파라미터화
- 모든 외부 입력 검증
- 적절한 HTTP 상태 코드 사용
```

**4. 프론트엔드 개발자**
```markdown
---
name: frontend-dev
description: UI 컴포넌트, 상태 관리, UX 전문가. 프론트엔드 구현에 사용.
tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
---

# 프론트엔드 개발자 에이전트

당신은 React/TypeScript로 모던 UI 개발을 전문으로 하는 시니어 프론트엔드 개발자입니다.

## 기술 전문성
- TypeScript와 훅을 사용한 React
- 상태 관리 (Context, Redux, React Query)
- 반응형 디자인을 위한 CSS/Tailwind
- 접근성 (WCAG 2.1 AA 준수)
- 성능 최적화

## 개발 표준
- 훅만 사용하는 함수형 컴포넌트
- TypeScript strict 모드 활성화
- React Testing Library로 컴포넌트 레벨 테스트
- 모바일 우선 반응형 디자인
- 모든 인터랙티브 요소에 접근성 속성

## 제약
- 인라인 스타일 금지 (Tailwind 또는 CSS 모듈 사용)
- 로딩, 에러, 빈 상태 항상 처리
- 인터랙티브 요소에 키보드 내비게이션 포함
- 시맨틱 HTML 요소 사용
```

**5. 코드 리뷰 전문가**
```markdown
---
name: code-reviewer
description: 품질, 보안, 유지보수성 리뷰 전문가. PR 병합 전 MUST BE USED.
tools: Read, Grep, Glob, Bash
model: sonnet
---

# 코드 리뷰어 에이전트

당신은 보안, 성능, 코드 품질 전문 시니어 코드 리뷰어입니다.

## 리뷰 범위
1. **보안**: OWASP Top 10, 입력 검증, 인증/인가
2. **성능**: 알고리즘 효율성, DB 쿼리, 캐싱
3. **유지보수성**: 가독성, 모듈성, 문서화
4. **테스팅**: 커버리지, 엣지 케이스, 테스트 품질
5. **규칙**: 프로젝트 표준 준수

## 출력 형식
각 이슈에 대해:
```markdown
### [심각도: Critical/High/Medium/Low]
**위치**: `파일명:라인번호`
**이슈**: 문제 설명
**위험**: 미해결 시 잠재적 영향
**권장사항**: 코드 예제와 함께 구체적 수정안
```

## 제약
- 파일 수정 금지
- Critical/High 보안 이슈가 있는 코드 승인 금지
- 각 발견사항에 대한 이유 항상 설명
```

**6-10. 추가 역할 구성**

| 역할 | 모델 | 핵심 도구 | 주요 책임 |
|------|------|----------|---------|
| **디자인 전문가** | sonnet | Read, Grep | UI/UX 가이드라인, 디자인 시스템 준수 검토 |
| **모바일 개발자** | sonnet | Read, Write, Edit, Bash | iOS/Android 네이티브 또는 React Native 개발 |
| **테스트 전문가** | haiku | Read, Bash, Glob | 테스트 실행, 결과 보고, 커버리지 분석 |
| **보안 감사자** | sonnet | Read, Grep, Glob | 보안 취약점 분석, OWASP 점검 |
| **DevOps 전문가** | sonnet | Bash, Read, Write | CI/CD, 인프라, 배포 자동화 |

### CLAUDE.md 프로젝트 설정

```markdown
# CLAUDE.md

## 프로젝트: 이커머스 플랫폼

## 기술 스택
- Frontend: React 18, TypeScript, TailwindCSS
- Backend: Node.js, Express, Prisma
- Database: PostgreSQL
- Testing: Jest, React Testing Library, Playwright

## 프로젝트 구조
```
├── apps/
│   ├── web/           # React 프론트엔드
│   └── api/           # Express 백엔드
├── packages/
│   ├── ui/            # 공유 UI 컴포넌트
│   └── shared/        # 공유 유틸리티
├── prisma/            # DB 스키마 및 마이그레이션
└── docs/              # 프로젝트 문서
```

## 공통 명령어
```bash
pnpm dev              # 개발 서버 시작
pnpm test             # 전체 테스트 실행
pnpm lint             # 린트 검사
pnpm build            # 프로덕션 빌드
```

## 에이전트 지침
- **ALWAYS**: 커밋 전 `pnpm lint` 실행
- **NEVER**: main 브랜치에 직접 커밋
- **USE**: Conventional Commit 메시지 사용
- **ASK**: 공유 패키지 리팩토링 전 승인 요청

## 멀티에이전트 워크플로우
복잡한 기능 처리 시:
1. @researcher로 요구사항 분석
2. @architect로 설계 검토
3. @backend-dev / @frontend-dev로 구현
4. @code-reviewer로 품질 검증
5. @test-runner로 테스트 실행
```

---

## 4. 작업 분해 및 할당 전략

### 기능 단위 작업 분해

**슬래시 커맨드 기반 오케스트레이션:**
```markdown
# .claude/commands/implement-feature.md
---
description: 멀티에이전트 기능 구현 오케스트레이션
argument-hint: "<기능 설명>"
---

당신은 메인 오케스트레이터입니다. 직접 구현하지 마세요.

## Phase 1: 기획 (병렬)
다음 기획 에이전트를 동시에 스폰:
- researcher: 요구사항 및 기존 패턴 조사
- architect: 전체 아키텍처 설계
- designer: UI/UX 접근 방식 계획

## Phase 2: 합성
모든 계획 검토, 충돌 해결, 통합 구현 계획 생성
출력: `state/implementation-plan.json`

## Phase 3: 구현 (병렬)
합성된 계획에 따라 구현 에이전트 스폰:
- backend-dev: API 구현
- frontend-dev: UI 구현
- mobile-dev: 모바일 앱 구현 (필요시)

## Phase 4: 검증
- code-reviewer: 변경사항 검토
- test-runner: 테스트 실행
- security-auditor: 보안 감사

## 조율 규칙
1. 각 단계 전 `state/progress.json` 확인
2. 태스크 완료 후 상태 업데이트
3. 계획에 명시된 의존성에서 블로킹
4. 블로커 발생 시 메인 스레드로 에스컬레이션
```

### 작업 의존성 그래프 관리

```json
// state/task-graph.json
{
  "tasks": [
    {
      "id": "research-auth",
      "agent": "researcher",
      "status": "completed",
      "dependencies": []
    },
    {
      "id": "design-auth-api",
      "agent": "architect",
      "status": "completed",
      "dependencies": ["research-auth"]
    },
    {
      "id": "impl-auth-backend",
      "agent": "backend-dev",
      "status": "in_progress",
      "dependencies": ["design-auth-api"]
    },
    {
      "id": "impl-auth-frontend",
      "agent": "frontend-dev",
      "status": "blocked",
      "dependencies": ["impl-auth-backend"],
      "blockedBy": "API 계약 대기 중"
    }
  ]
}
```

### 노력 규모 조정 규칙

| 작업 유형 | 에이전트 수 | 도구 호출 |
|----------|-----------|---------|
| 단순 팩트 파인딩 | 1 | 3-10 |
| 직접 비교 | 2-4 | 각 10-15 |
| 복잡한 리서치/구현 | 5-10 | 분할된 책임 |

---

## 5. 에이전트 간 통신 및 상태 관리

### 파일 시스템 기반 상태 공유

**프로젝트 상태 파일 구조:**
```
state/
├── project-state.json      # 전체 프로젝트 상태
├── task-queue.json         # 대기 중인 작업 큐
├── agent-status/           # 에이전트별 상태
│   ├── backend-dev.json
│   ├── frontend-dev.json
│   └── ...
├── checkpoints/            # 체크포인트 저장소
│   └── checkpoint-001.json
└── outputs/                # 에이전트 산출물
    ├── research-report.md
    └── api-contract.json
```

### 구조화된 에이전트 간 메시지 프로토콜

```typescript
// 에이전트 간 메시지 형식
interface AgentMessage {
  messageId: string;
  fromAgent: string;
  toAgent: string;
  type: 'task_assignment' | 'status_update' | 'feedback' | 'completion';
  payload: {
    taskId: string;
    content: any;
    priority: 'high' | 'medium' | 'low';
    deadline?: string;
  };
  timestamp: string;
}

// 태스크 핸드오프 예시
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
  "timestamp": "2025-12-31T10:30:00Z"
}
```

### 팀장-팀원 피드백 루프

```markdown
# state/project-state.md

## 현재 스프린트: 사용자 인증 기능

### 태스크 분해
- [x] 인증 패턴 리서치 (@researcher, 완료)
- [x] DB 스키마 설계 (@architect, 완료)
- [ ] 인증 서비스 구현 (@backend-dev, 진행중: 60%)
- [ ] 로그인 UI 생성 (@frontend-dev, 차단됨: API 대기)
- [ ] 통합 테스트 작성 (@test-runner, 대기)
- [ ] 보안 리뷰 (@security-auditor, 대기)

### 체크포인트: 2025-12-31 10:00
- 스키마 마이그레이션 생성 및 테스트 완료
- JWT 서비스 스캐폴딩 완료
- 차단됨: Rate limiting 결정 필요

### 다음 액션
1. 인증 서비스 구현 완료
2. API 계약으로 프론트엔드 차단 해제
```

---

## 6. 오픈소스 구현 사례 및 참조

### 주요 GitHub 프로젝트

| 프로젝트 | 설명 | 핵심 기능 |
|---------|------|----------|
| **[ruvnet/claude-flow](https://github.com/ruvnet/claude-flow)** | Claude용 선도적 에이전트 오케스트레이션 플랫폼 | Hive-Mind, 100+ MCP 도구, swarm 오케스트레이션 |
| **[wshobson/agents](https://github.com/wshobson/agents)** | 프로덕션 수준 멀티에이전트 시스템 | 99개 전문 에이전트, 15개 워크플로우 오케스트레이터 |
| **[smtg-ai/claude-squad](https://github.com/smtg-ai/claude-squad)** | 다중 AI 터미널 에이전트 관리 | tmux + git worktrees 활용 |
| **[VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)** | 100+ 전문 서브에이전트 컬렉션 | 풀스택, DevOps, 데이터 사이언스 에이전트 |

### Anthropic 공식 리소스

| 리소스 | URL | 핵심 내용 |
|--------|-----|---------|
| **멀티에이전트 리서치 시스템** | anthropic.com/engineering/multi-agent-research-system | 오케스트레이터-워커 패턴, 프롬프트 엔지니어링, 평가 전략 |
| **효과적인 에이전트 구축** | anthropic.com/research/building-effective-agents | 워크플로우 vs 에이전트, 도구 설계, ACI 패턴 |
| **Claude Code 모범 사례** | anthropic.com/engineering/claude-code-best-practices | 서브에이전트 사용법, 슬래시 커맨드, 커스텀 설정 |

### Claude-Flow 사용 예시

```bash
# 스웜으로 빠른 태스크 실행
npx claude-flow@alpha swarm "인증이 포함된 REST API 빌드" --claude

# 멀티에이전트 조율
npx claude-flow@alpha swarm init --topology mesh --max-agents 5
npx claude-flow@alpha swarm spawn researcher "API 패턴 분석"
npx claude-flow@alpha swarm spawn coder "엔드포인트 구현"

# 하이브마인드 오케스트레이션
npx claude-flow@alpha hive-mind spawn "엔터프라이즈 시스템 빌드" --claude
```

---

## 7. 성능 최적화 및 비용 관리

### API 호출 최소화 전략

**프롬프트 캐싱 (최고 영향):**
- 캐시 읽기 토큰: **$0.30/MTok** vs 일반 입력 **$3.00/MTok** (90% 절감)
- 5분 캐시: 쓰기 1.25x, 읽기 0.1x
- 1시간 캐시: 쓰기 2x, 읽기 0.1x

**배치 처리:**
- Anthropic Batch API: 입력/출력 토큰 모두 **50% 할인**
- 최적 배치 크기: 1-64 요청

**스마트 모델 라우팅:**
```python
# 캐스케이드 접근: 저렴한 모델 우선, 필요시 에스컬레이션
def route_to_model(task_complexity):
    if task_complexity == 'simple':
        return 'haiku'  # $0.80/MTok
    elif task_complexity == 'medium':
        return 'sonnet'  # $3/MTok
    else:
        return 'opus'   # $5/MTok (리드/오케스트레이터 전용)
```

### 컨텍스트 윈도우 효율적 사용

**요약 기반 압축:**
```python
class ContextCompressor:
    def compress(self, conversation):
        if len(conversation) > THRESHOLD:
            # 최근 N개 턴은 그대로 유지
            recent = conversation[-N:]
            # 나머지는 요약
            older = conversation[:-N]
            summary = self.summarize(older)
            return [summary] + recent
        return conversation
```

**계층적 메모리 아키텍처:**
- **단기 메모리**: 최근 턴 전체 보존
- **중기 메모리**: 최근 세션의 압축 요약
- **장기 메모리**: 핵심 사실 및 관계 추출

### 토큰 사용량 모니터링

**Anthropic Usage & Cost API:**
```bash
# 사용량 추적
GET /v1/organizations/usage_report/messages

# 비용 추적
GET /v1/organizations/cost_report
```

**모니터링 지표:**
- 비캐시/캐시 입력, 캐시 생성, 출력 토큰
- API 키, 워크스페이스, 모델별 필터/그룹화
- 시간 버킷: 1m (실시간), 1h (일일), 1d (주간/월간)

### 비용 효율적 아키텍처

| 모델 | 입력/MTok | 출력/MTok | 용도 |
|------|----------|----------|------|
| Haiku 3.5 | $0.80 | $4 | 라우팅, 분류, 단순 검증 |
| Sonnet 4 | $3 | $15 | 서브에이전트, 일반 작업, 코딩 |
| Opus 4 | $5 | $25 | 리드 오케스트레이터, 복잡한 추론 |

**토큰 사용량 비교:**

| 모드 | 토큰 사용량 |
|------|-----------|
| 채팅 | 1x (기준) |
| 단일 에이전트 | 4x |
| 멀티에이전트 | 15x |

**예상 종합 절감:**
- 프롬프트 캐싱 + 배치: ~95% 절감 (적격 워크로드)
- 모델 라우팅 + 프롬프트 최적화: 60-80% 절감
- 컨텍스트 압축: 인스턴스당 50%+ 절감
- **전체: 40-80% 비용 절감 달성 가능**

---

## 8. 품질 관리 워크플로우

### 코드 리뷰 에이전트 구현

**품질 게이트 설정:**
```yaml
# quality-gates.yaml
quality_gates:
  coverage:
    threshold: 85
    ignore_patterns: ["*/tests/*", "*/migrations/*"]
  complexity:
    max_function_complexity: 8
    max_file_complexity: 50
  security:
    allow_medium_vulns: false
    max_high_vulns: 0
  performance:
    max_regression_percent: 5
    timeout_seconds: 300
```

**다단계 QA 파이프라인:**
```
1. Lint (병렬)
2. Unit 테스트 (80%+ 커버리지 임계값)
3. Integration 테스트 (타임아웃: 600s)
4. Security 스캔 (fail-fast)
5. Performance 테스트 (베이스라인 비교)
```

### 자동화된 테스트 통합

**Claude Code 테스트 자동화 결과:**
- 전체 유닛 테스트 커버리지: **~2시간 vs ~6시간** (수동)
- 통합 테스트 설정: 생성된 픽스처로 **~40% 빠름**
- PR 사이클 시간: 상당히 단축

### LLM-as-Judge 평가 기준

| 기준 | 설명 |
|------|------|
| **사실적 정확성** | 주장이 소스와 일치하는가? |
| **인용 정확성** | 인용된 소스가 주장과 일치하는가? |
| **완전성** | 요청된 모든 측면이 다루어졌는가? |
| **소스 품질** | 1차 소스가 2차보다 우선인가? |
| **도구 효율성** | 올바른 도구, 합리적인 횟수? |

### 최종 산출물 검증 프로세스

**CitationAgent 패턴 (Anthropic):**
1. 전용 에이전트가 리서치 보고서 처리
2. 인용이 필요한 위치 식별
3. 모든 주장이 올바르게 귀속되었는지 확인
4. 인용이 포함된 최종 검증 출력 반환

**휴먼 오버사이트 레이어:**
- 자동화된 평가가 놓친 엣지 케이스 포착
- 소스 선택 편향 식별
- 비정상적 쿼리 검토
- AI 생성 수정사항 배포 전 검토

---

## 아키텍처 다이어그램: 전체 시스템

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          사용자 인터페이스                                │
│                  (CLI / Web Dashboard / IDE 통합)                       │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       팀장 (매니저 에이전트)                              │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ Model: Opus 4                                                    │   │
│  │ 책임: 작업 분해, 의존성 분석, 에이전트 할당, 진행 추적              │   │
│  │ 도구: Task, Read, Write, Glob, Grep                              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    기획팀        │    │     개발팀       │    │     품질팀       │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • 리서처        │    │ • 백엔드 개발자  │    │ • 코드 리뷰어    │
│ • 설계자        │    │ • 프론트엔드     │    │ • 테스트 전문가  │
│ • 디자이너      │    │ • 모바일 개발자  │    │ • 보안 감사자    │
│                 │    │ • DevOps        │    │                 │
│ Model: Sonnet   │    │ Model: Sonnet   │    │ Model: Sonnet/  │
│                 │    │                 │    │        Haiku    │
└────────┬────────┘    └────────┬────────┘    └────────┬────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         공유 상태 레이어                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   태스크     │  │  체크포인트  │  │   산출물    │  │   메모리    │    │
│  │    큐       │  │    저장소    │  │   저장소    │  │   저장소    │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
│                    state/ 디렉토리 기반 파일 시스템                       │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 구현 시 주의사항 및 한계점

### 핵심 한계

| 한계 | 설명 | 우회 방법 |
|------|------|----------|
| **중첩 서브에이전트 불가** | 서브에이전트가 서브에이전트 스폰 불가 | Bash로 `claude -p` 호출 (비권장) |
| **10개 동시 실행 제한** | 추가 태스크는 큐잉됨 | 배치 전략으로 우선순위 관리 |
| **토큰 비용** | 멀티에이전트는 15x 토큰 사용 | 고부가가치 작업에만 선택적 적용 |
| **컨텍스트 격리** | 에이전트 간 직접 통신 불가 | 파일 시스템 기반 상태 공유 |
| **Windows 제한** | 긴 프롬프트(>8191자) CLI 실패 | 마크다운 파일 방식 사용 |

### 모범 사례 요약

1. **시스템 프롬프트**: 역할 중심, 명확한 책임, 제약, 출력 형식 정의
2. **CLAUDE.md**: 단순 시작, 실제 마찰점 기반 확장; 진화하는 문서로 취급
3. **지식 주입**: CLAUDE.md, MCP 서버, 스킬 파일 조합 활용
4. **도구 제어**: settings.json에서 allow/deny 리스트 사용; 서브에이전트는 최소 필요 도구로 제한
5. **통신**: 에이전트 간 조율에 파일 기반 JSON 상태 사용; 체크포인트 시스템 구현
6. **상태 관리**: 세션(임시)과 영구 상태 분리; 구조화된 진행 추적 사용

### 성공 지표

| 지표 | 목표 |
|------|------|
| 태스크 완료율 | >95% |
| 평균 에이전트 호출 시간 | <30초 |
| 토큰 효율성 | 태스크당 <50K 토큰 |
| 품질 게이트 통과율 | >90% |
| 비용 최적화 | 기준 대비 40-60% 절감 |

이 가이드는 Claude Code CLI의 현재 기능을 기반으로 하며, Anthropic의 지속적인 업데이트에 따라 새로운 기능이 추가될 수 있다. 최신 정보는 [공식 문서](https://code.claude.com/docs)를 참조하라.