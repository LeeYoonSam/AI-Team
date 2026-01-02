# AI 개발팀 멀티에이전트 오케스트레이션 시스템

[![Agents](https://img.shields.io/badge/Agents-11-blue)](docs/agents.md)
[![Commands](https://img.shields.io/badge/Commands-14-green)](docs/workflows.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-CLI-purple)](https://claude.ai)
[![License](https://img.shields.io/badge/License-MIT-yellow)](#license)

Claude Code CLI의 서브에이전트 기능을 활용하여 **11명의 전문가 에이전트**가 협업하는 AI 개발팀 시스템입니다.

## 프로젝트 소개

복잡한 소프트웨어 개발 작업을 여러 전문 에이전트가 병렬로 처리하여 효율성을 극대화합니다. 기획부터 개발, 테스트, 배포까지 전체 개발 라이프사이클을 자동화된 워크플로우로 관리합니다.

### 핵심 가치

- **전문성**: 각 에이전트가 특정 도메인에 특화
- **병렬 처리**: 독립적인 작업의 동시 수행
- **품질 보장**: 코드 리뷰, 테스트, 보안 검사 자동화
- **일관성**: 파일 기반 상태 관리로 작업 추적

## 핵심 특징

| 특징 | 설명 |
|-----|------|
| **11명의 전문가 에이전트** | 매니저 + 기획팀(3) + 개발팀(4) + 품질팀(3) |
| **4단계 병렬 워크플로우** | 기획 → 구현 → 검증 → 배포 |
| **14개 슬래시 커맨드** | 프로젝트 관리, 기능 개발, 리뷰, 테스트, Git 자동화 |
| **파일 기반 상태 관리** | 에이전트 간 통신 및 체크포인트 |
| **자동화된 Git Hooks** | 커밋 메시지, 문서 동기화 자동화 |

## 빠른 시작

```bash
# 1. 저장소 클론
git clone https://github.com/your-repo/ai-team.git
cd ai-team

# 2. 초기 설정 (Git Hooks 설치)
./scripts/setup.sh

# 3. 프로젝트 초기화
/project:init
```

> 상세한 설정 방법은 [시작 가이드](docs/getting-started.md)를 참조하세요.

## 팀 구성

### 매니저
| 에이전트 | 모델 | 역할 |
|---------|------|------|
| Manager | Opus 4 | 작업 분해, 에이전트 할당, 진행 관리 |

### 기획팀
| 에이전트 | 모델 | 역할 |
|---------|------|------|
| Researcher | Sonnet | 기술 조사, 패턴 분석 |
| Architect | Opus | 시스템 설계, API 설계 |
| Designer | Sonnet | UI/UX 설계 |

### 개발팀
| 에이전트 | 모델 | 역할 |
|---------|------|------|
| Backend Dev | Sonnet | API 구현, DB 작업 |
| Frontend Dev | Sonnet | UI 컴포넌트, 상태 관리 |
| Mobile Dev | Sonnet | iOS/Android/React Native |
| DevOps | Sonnet | CI/CD, 인프라, 배포 |

### 품질팀
| 에이전트 | 모델 | 역할 |
|---------|------|------|
| Code Reviewer | Sonnet | 코드 품질, 유지보수성 |
| Tester | Haiku | 테스트 작성, 커버리지 |
| Security Auditor | Sonnet | 보안 취약점, OWASP |

> 각 에이전트의 상세 정의는 [에이전트 문서](docs/agents.md)를 참조하세요.

## 주요 명령어

| 카테고리 | 명령어 | 설명 |
|---------|--------|------|
| **프로젝트** | `/project:init` | 프로젝트 초기화 |
| | `/project:status` | 상태 확인 |
| **기능 개발** | `/feature:implement <기능>` | 멀티에이전트 오케스트레이션으로 구현 |
| | `/feature:research <주제>` | 기술 리서치 |
| | `/feature:design <기능>` | 시스템 설계 |
| **리뷰** | `/review:code` | 코드 리뷰 |
| | `/review:security` | 보안 리뷰 |
| **테스트** | `/test:run` | 테스트 실행 |
| | `/test:coverage` | 커버리지 분석 |
| **Git** | `/git:commit` | 자동 커밋 |
| | `/git:pr` | PR 생성 |

> 전체 명령어 목록과 상세 사용법은 [워크플로우 문서](docs/workflows.md)를 참조하세요.

## 프로젝트 구조

```
.
├── .claude/
│   ├── agents/        # 에이전트 정의 (11개)
│   ├── commands/      # 슬래시 커맨드 (14개)
│   └── settings.json  # 권한 설정
├── state/
│   ├── project-state.json  # 프로젝트 상태
│   ├── task-queue.json     # 작업 대기열
│   ├── agents/             # 에이전트별 상태
│   └── checkpoints/        # 체크포인트
├── docs/              # 문서
├── scripts/           # 자동화 스크립트
└── templates/         # 템플릿
```

> 상세한 아키텍처는 [아키텍처 문서](docs/architecture.md)를 참조하세요.

## 워크플로우 예시

### 기능 구현 (`/feature:implement`)

```
/feature:implement 사용자 인증 기능 구현
```

**실행 흐름**:
1. **Phase 1 (기획)**: Researcher, Architect, Designer가 병렬로 조사 및 설계
2. **Phase 2 (구현)**: Backend, Frontend, Mobile 개발자가 병렬로 구현
3. **Phase 3 (검증)**: Code Reviewer, Tester, Security Auditor가 병렬로 검증
4. **Phase 4 (배포)**: DevOps가 배포 준비

> 실제 프로젝트 적용 예시는 [실제 프로젝트 적용 가이드](docs/practical-guide.md)를 참조하세요.

## 문서

| 문서 | 설명 |
|-----|------|
| [시작 가이드](docs/getting-started.md) | 설치, 설정, 기본 사용법 |
| [아키텍처](docs/architecture.md) | 시스템 구조, 핵심 원칙 |
| [에이전트 정의](docs/agents.md) | 11개 에이전트 상세 정의 |
| [워크플로우](docs/workflows.md) | 슬래시 커맨드, 작업 흐름 |
| [상태 관리](docs/state-management.md) | 파일 기반 통신, 체크포인트 |
| [자동화](docs/automation.md) | Git Hooks, 문서 동기화 |
| [실제 적용 가이드](docs/practical-guide.md) | 5가지 실제 시나리오, 커스터마이징 |

## 요구사항

- Claude Code CLI
- Git 2.x+
- Node.js 18+ (선택)

## License

MIT License - 자유롭게 사용, 수정, 배포할 수 있습니다.

---

Made with Claude Code CLI
