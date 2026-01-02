#!/bin/bash

# ============================================
# AI 개발팀 멀티에이전트 시스템 초기 설정 스크립트
# ============================================

echo "🚀 AI 개발팀 멀티에이전트 시스템 설정을 시작합니다..."

# Git 초기화 (이미 되어있다면 스킵)
if [ ! -d ".git" ]; then
    git init
    echo "✅ Git 저장소 초기화 완료"
else
    echo "ℹ️  Git 저장소가 이미 존재합니다"
fi

# Git Hooks 디렉토리 생성
mkdir -p .git/hooks

# ============================================
# pre-commit hook
# ============================================
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# 린트 검사 (Node.js 프로젝트)
if command -v npm &> /dev/null && [ -f "package.json" ]; then
    if grep -q '"lint"' package.json; then
        echo "🔍 린트 검사 중..."
        npm run lint || exit 1
    fi
fi

# 린트 검사 (Python 프로젝트)
if command -v python3 &> /dev/null && [ -f "pyproject.toml" ]; then
    if command -v ruff &> /dev/null; then
        echo "🔍 Python 린트 검사 중..."
        ruff check . || exit 1
    fi
fi

# 민감 정보 검사
echo "🔒 민감 정보 검사 중..."

# 하드코딩된 비밀번호 검사
if grep -rn "password\s*=\s*['\"][^'\"]*['\"]" --include="*.ts" --include="*.js" --include="*.py" --include="*.java" . 2>/dev/null | grep -v "node_modules" | grep -v ".git"; then
    echo "⚠️  경고: 하드코딩된 비밀번호가 감지되었습니다."
    exit 1
fi

# 하드코딩된 API 키 검사
if grep -rn "api_key\s*=\s*['\"][^'\"]*['\"]" --include="*.ts" --include="*.js" --include="*.py" --include="*.java" . 2>/dev/null | grep -v "node_modules" | grep -v ".git"; then
    echo "⚠️  경고: 하드코딩된 API 키가 감지되었습니다."
    exit 1
fi

# 하드코딩된 시크릿 검사
if grep -rn "secret\s*=\s*['\"][^'\"]*['\"]" --include="*.ts" --include="*.js" --include="*.py" --include="*.java" . 2>/dev/null | grep -v "node_modules" | grep -v ".git"; then
    echo "⚠️  경고: 하드코딩된 시크릿이 감지되었습니다."
    exit 1
fi

echo "✅ 사전 검사 통과"
exit 0
EOF

# ============================================
# post-commit hook
# ============================================
cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash

# 마지막 커밋에서 변경된 파일 확인
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)

# 소스 코드 변경 시 문서 업데이트 필요 표시
if echo "$CHANGED_FILES" | grep -q "^src/"; then
    mkdir -p .claude
    echo "DOC_UPDATE_NEEDED" > .claude/doc-update-flag
    echo "ℹ️  소스 코드 변경 감지: 문서 업데이트가 필요할 수 있습니다."
fi

# 에이전트 변경 시 문서 업데이트 필요 표시
if echo "$CHANGED_FILES" | grep -q "^\.claude/agents/"; then
    mkdir -p .claude
    echo "AGENT_DOC_UPDATE" >> .claude/doc-update-flag
    echo "ℹ️  에이전트 변경 감지: docs/agents.md 업데이트가 필요합니다."
fi

# 커맨드 변경 시 문서 업데이트 필요 표시
if echo "$CHANGED_FILES" | grep -q "^\.claude/commands/"; then
    mkdir -p .claude
    echo "WORKFLOW_DOC_UPDATE" >> .claude/doc-update-flag
    echo "ℹ️  커맨드 변경 감지: docs/workflows.md 업데이트가 필요합니다."
fi

# 상태 파일 업데이트
if [ -f "state/project-state.json" ]; then
    # jq가 있으면 사용
    if command -v jq &> /dev/null; then
        COMMIT_HASH=$(git rev-parse HEAD)
        COMMIT_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        jq ".lastCommit = \"$COMMIT_HASH\" | .lastCommitTime = \"$COMMIT_TIME\"" \
            state/project-state.json > state/project-state.json.tmp && \
            mv state/project-state.json.tmp state/project-state.json
    fi
fi

exit 0
EOF

# ============================================
# prepare-commit-msg hook
# ============================================
cat > .git/hooks/prepare-commit-msg << 'EOF'
#!/bin/bash

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# 템플릿 메시지 추가 (수동 커밋 시에만)
if [ -z "$COMMIT_SOURCE" ]; then
    # 기존 메시지가 비어있을 때만 템플릿 추가
    if [ ! -s "$COMMIT_MSG_FILE" ]; then
        cat > "$COMMIT_MSG_FILE" << 'TEMPLATE'

# ============================================
# 커밋 메시지 가이드
# ============================================
# 형식: <type>: <subject>
#
# 타입:
#   feat     - 새로운 기능
#   fix      - 버그 수정
#   docs     - 문서 변경
#   style    - 코드 스타일 변경 (포맷팅 등)
#   refactor - 리팩토링
#   test     - 테스트 추가/수정
#   chore    - 기타 변경 (빌드, 패키지 등)
#
# 규칙:
#   - 첫 줄: 50자 이내
#   - 본문: 72자 줄바꿈
#   - 한국어로 작성
#   - 현재형 사용 (예: "추가" not "추가함")
#
# 예시:
#   feat: 사용자 로그인 기능 추가
#   fix: 로그인 시 비밀번호 검증 오류 수정
#   docs: API 문서 업데이트
# ============================================
TEMPLATE
    fi
fi
EOF

# 훅 실행 권한 부여
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/post-commit
chmod +x .git/hooks/prepare-commit-msg

echo "✅ Git Hooks 설치 완료"

# ============================================
# 디렉토리 구조 생성
# ============================================
echo "📁 디렉토리 구조 생성 중..."

# .claude 디렉토리
mkdir -p .claude/agents
mkdir -p .claude/commands/project
mkdir -p .claude/commands/feature
mkdir -p .claude/commands/review
mkdir -p .claude/commands/test
mkdir -p .claude/commands/docs
mkdir -p .claude/commands/git
mkdir -p .claude/skills

# state 디렉토리
mkdir -p state/agents
mkdir -p state/checkpoints
mkdir -p state/outputs

# 기타 디렉토리
mkdir -p docs
mkdir -p scripts
mkdir -p templates

echo "✅ 디렉토리 구조 생성 완료"

# ============================================
# 완료 메시지
# ============================================
echo ""
echo "============================================"
echo "🎉 AI 개발팀 멀티에이전트 시스템 설정 완료!"
echo "============================================"
echo ""
echo "다음 단계:"
echo "  1. Claude Code 시작: claude"
echo "  2. 상태 확인: /project:status"
echo "  3. 시작 가이드 참조: docs/getting-started.md"
echo ""
