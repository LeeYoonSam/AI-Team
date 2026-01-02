# AI 개발팀 멀티에이전트 오케스트레이션 시스템

## 프로젝트 개요

이 프로젝트는 Claude Code CLI의 서브에이전트 기능을 활용한 **10명의 전문가 에이전트**로 구성된 AI 개발팀입니다.

## 팀 구성

### 매니저 (Team Manager)
- **모델**: Opus 4
- **역할**: 작업 분해, 에이전트 할당, 진행 관리, 결과 통합
- **호출**: 복잡한 작업, 여러 에이전트 협업 필요 시

### 기획팀
| 에이전트 | 모델 | 역할 |
|---------|------|------|
| 리서처 | Sonnet | 기술 조사, 패턴 분석, 정보 수집 |
| 아키텍트 | Opus | 시스템 설계, API 설계, 기술 결정 |
| 디자이너 | Sonnet | UI/UX 설계, 디자인 시스템 관리 |

### 개발팀
| 에이전트 | 모델 | 역할 |
|---------|------|------|
| 백엔드 개발자 | Sonnet | API 구현, 데이터베이스 작업 |
| 프론트엔드 개발자 | Sonnet | UI 컴포넌트, 상태 관리 |
| 모바일 개발자 | Sonnet | iOS/Android/React Native 개발 |
| DevOps | Sonnet | CI/CD, 인프라, 배포 자동화 |

### 품질팀
| 에이전트 | 모델 | 역할 |
|---------|------|------|
| 코드 리뷰어 | Sonnet | 코드 품질, 보안, 유지보수성 리뷰 |
| 테스터 | Haiku | 테스트 작성, 실행, 커버리지 분석 |
| 보안 감사자 | Sonnet | 보안 취약점 분석, OWASP 점검 |

## 프로젝트 구조

```
.claude/
├── agents/           # 에이전트 정의
├── commands/         # 슬래시 커맨드
└── settings.json     # 설정

state/                # 상태 관리
├── project-state.json
├── task-queue.json
├── agents/
├── checkpoints/
└── outputs/

docs/                 # 프로젝트 문서
scripts/              # 자동화 스크립트
templates/            # 템플릿
```

## 주요 슬래시 커맨드

### 프로젝트 관리
- `/project:init` - 프로젝트 초기화
- `/project:status` - 상태 확인
- `/project:sync` - 문서 동기화

### 기능 개발
- `/feature:implement <기능>` - 멀티에이전트 오케스트레이션으로 기능 구현
- `/feature:research <주제>` - 기술 리서치
- `/feature:design <기능>` - 설계

### 리뷰
- `/review:code` - 코드 리뷰
- `/review:security` - 보안 리뷰

### 테스트
- `/test:run` - 테스트 실행
- `/test:coverage` - 커버리지 분석

### Git
- `/git:commit` - 자동 커밋
- `/git:pr` - PR 생성

### 문서
- `/docs:sync` - 문서 동기화

## 공통 규칙

### 코드 스타일
- 모든 함수에 타입 힌트 필수
- 의미 있는 변수/함수명 사용
- 공개 API에 문서화 필수

### Git 규칙
- Conventional Commit 메시지 사용
- 파일 변경 시 자동 커밋
- main 브랜치 직접 커밋 금지

### 문서 규칙
- 모든 문서는 한국어로 작성
- 설계/기능 변경 시 관련 문서 자동 업데이트
- 변경 이력 섹션 유지

## 에이전트 호출 방법

### 자동 호출
에이전트의 description에 명시된 트리거 조건에 따라 자동 호출

### 명시적 호출
```
@researcher 사용자 인증 기술 조사해줘
@backend-dev 로그인 API 구현해줘
```

### 오케스트레이션
```
/feature:implement 사용자 인증 기능 구현
```

## 상태 관리

에이전트 간 통신은 `state/` 디렉토리의 JSON 파일을 통해 이루어집니다.
- `project-state.json`: 전체 프로젝트 상태
- `task-queue.json`: 작업 대기열
- `agents/{agent}.json`: 에이전트별 상태

## 문서 참조

- [시작 가이드](docs/getting-started.md)
- [실제 프로젝트 적용 가이드](docs/practical-guide.md) ⭐
- [시스템 아키텍처](docs/architecture.md)
- [에이전트 정의](docs/agents.md)
- [워크플로우](docs/workflows.md)
- [상태 관리](docs/state-management.md)
- [자동화 기능](docs/automation.md)
