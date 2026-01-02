# 자동화 기능

## 개요

이 문서는 시스템의 자동화 기능을 설명합니다. Git 자동 커밋, 문서 동기화, Git Hooks 등이 포함됩니다.

## Git Hooks

### 설치 방법

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 설치되는 훅

#### pre-commit

커밋 전에 실행되는 훅입니다.

**기능**:
- 린트 검사 (프로젝트에 따라)
- 민감 정보 검사 (하드코딩된 시크릿 탐지)

**스크립트**:
```bash
#!/bin/bash

# 린트 검사
if command -v npm &> /dev/null && [ -f "package.json" ]; then
    if grep -q '"lint"' package.json; then
        npm run lint || exit 1
    fi
fi

# 민감 정보 검사
if grep -rn "password\s*=\s*['\"][^'\"]*['\"]" --include="*.{ts,js,py}" .; then
    echo "경고: 하드코딩된 비밀번호가 감지되었습니다."
    exit 1
fi
```

#### post-commit

커밋 후에 실행되는 훅입니다.

**기능**:
- 소스 코드 변경 시 문서 업데이트 플래그 설정
- 프로젝트 상태 파일 업데이트

#### prepare-commit-msg

커밋 메시지 작성 시 실행되는 훅입니다.

**기능**:
- 커밋 메시지 템플릿 제공
- Conventional Commit 형식 안내

### 훅 비활성화

```bash
git config core.hooksPath .git/hooks.disabled
```

### 훅 재활성화

```bash
git config core.hooksPath .git/hooks
```

---

## 자동 Git 커밋

### 슬래시 커맨드

```
/git:commit              # 변경사항 자동 커밋 (메시지 자동 생성)
/git:commit feat: 로그인  # 지정된 메시지로 커밋
```

### 커밋 메시지 형식

```
<type>: <subject>

[optional body]

[optional footer]
```

### 타입

| 타입 | 설명 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 수정 |
| `style` | 코드 포맷팅 |
| `refactor` | 코드 리팩토링 |
| `test` | 테스트 코드 |
| `chore` | 빌드, 패키지 등 |

### 자동 제외 파일

다음 파일은 자동으로 커밋에서 제외됩니다:
- `state/agents/*.json`
- `state/checkpoints/*.json`
- `*.log`
- `.DS_Store`
- `Thumbs.db`

---

## 문서 자동 동기화

### 트리거 조건

1. **코드 변경**: `src/` 디렉토리 파일 변경 시
2. **에이전트 변경**: `.claude/agents/` 변경 시
3. **워크플로우 변경**: `.claude/commands/` 변경 시
4. **수동 트리거**: `/docs:sync` 커맨드 실행

### 매핑 규칙

| 변경 경로 | 업데이트 문서 |
|----------|--------------|
| `.claude/agents/` | `docs/agents.md` |
| `.claude/commands/` | `docs/workflows.md` |
| `src/api/` | `docs/architecture.md` |
| `state/` | `docs/state-management.md` |
| `scripts/` | `docs/automation.md` |

### 슬래시 커맨드

```
/docs:sync           # 변경 감지 후 자동 동기화
/docs:update agents  # 특정 문서 수동 업데이트
```

### 업데이트 프로세스

1. 변경된 파일 감지
2. 관련 문서 식별
3. 문서 내용 업데이트
4. 변경 이력 기록
5. 자동 커밋 (선택적)

---

## 초기 설정 스크립트

### scripts/setup.sh

프로젝트 초기 설정을 위한 스크립트입니다.

**기능**:
1. Git 초기화 (필요 시)
2. Git Hooks 설치
3. 디렉토리 구조 생성
4. 실행 권한 설정

### 사용 방법

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 스크립트 내용

```bash
#!/bin/bash

# Git 초기화 (이미 되어있다면 스킵)
if [ ! -d ".git" ]; then
    git init
    echo "Git 저장소 초기화 완료"
fi

# Git Hooks 설치
mkdir -p .git/hooks

# pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# 린트 및 민감 정보 검사
EOF

# post-commit hook
cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash
# 문서 업데이트 플래그 설정
EOF

# 실행 권한 부여
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/post-commit

echo "Git Hooks 설치 완료"

# 디렉토리 구조 생성
mkdir -p .claude/agents
mkdir -p .claude/commands
mkdir -p .claude/skills
mkdir -p state/agents
mkdir -p state/checkpoints
mkdir -p state/outputs
mkdir -p docs
mkdir -p scripts
mkdir -p templates

echo "디렉토리 구조 생성 완료"
```

---

## 자동화 워크플로우

### 기능 구현 완료 시

```
기능 구현 완료
    │
    ▼
/docs:sync (문서 동기화)
    │
    ▼
/git:commit (자동 커밋)
    │
    ▼
완료
```

### 코드 리뷰 후

```
코드 리뷰 완료
    │
    ▼
문제 없음? ──▶ /git:commit
    │
    ▼
문제 있음 ──▶ 수정 후 재리뷰
```

---

## 트러블슈팅

### 훅이 실행되지 않을 때

1. 실행 권한 확인:
```bash
ls -la .git/hooks/
```

2. 권한 부여:
```bash
chmod +x .git/hooks/*
```

### 문서 동기화가 안 될 때

1. 변경 사항 확인:
```bash
git diff --name-only
```

2. 수동 동기화:
```
/docs:sync
```

### 커밋이 거부될 때

1. pre-commit 오류 확인
2. 린트 오류 수정
3. 민감 정보 제거

## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| 2024-01-15 | 초기 문서 작성 | AI Agent |
