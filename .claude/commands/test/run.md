---
description: 테스트를 실행하고 결과를 분석합니다.
argument-hint: [unit|integration|e2e|all]
allowed-tools: Bash, Read, Glob
model: haiku
---

# 테스트 실행

## 테스트 범위
$ARGUMENTS (기본값: all)

## 테스트 프레임워크 감지

### Node.js 프로젝트
```bash
# package.json 확인
if [ -f "package.json" ]; then
    # Jest
    if grep -q "jest" package.json; then
        npm test
    # Vitest
    elif grep -q "vitest" package.json; then
        npx vitest run
    # Mocha
    elif grep -q "mocha" package.json; then
        npx mocha
    fi
fi
```

### Python 프로젝트
```bash
# pytest
if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
    pytest
fi
```

### Go 프로젝트
```bash
if [ -f "go.mod" ]; then
    go test ./...
fi
```

## 테스트 범위별 실행

### unit
단위 테스트만 실행:
```bash
npm test -- --testPathPattern="unit"
# 또는
pytest -m unit
```

### integration
통합 테스트 실행:
```bash
npm test -- --testPathPattern="integration"
# 또는
pytest -m integration
```

### e2e
E2E 테스트 실행:
```bash
npm run test:e2e
# 또는
pytest -m e2e
```

### all
모든 테스트 실행:
```bash
npm test
# 또는
pytest
```

## 커버리지 수집

```bash
# Jest
npm test -- --coverage

# pytest
pytest --cov=src --cov-report=html
```

## 출력 형식

```markdown
# 테스트 실행 리포트

## 실행 정보
- 실행 일시: {일시}
- 테스트 범위: {범위}
- 실행 시간: {시간}

## 결과 요약

| 구분 | 통과 | 실패 | 스킵 | 총계 |
|------|-----|------|-----|-----|
| 단위 | 0 | 0 | 0 | 0 |
| 통합 | 0 | 0 | 0 | 0 |
| E2E | 0 | 0 | 0 | 0 |

## 커버리지

| 구분 | 커버리지 | 목표 | 상태 |
|------|---------|------|-----|
| Lines | 0% | 80% | - |
| Branches | 0% | 75% | - |
| Functions | 0% | 85% | - |

## 실패 분석

### 실패 1
**테스트**: {테스트명}
**파일**: {파일}:{라인}
**오류**: {오류 메시지}
**원인**: {분석}
**권장 조치**: {조치}

## 권장사항
{개선 사항}
```

## 산출물

**파일**: `state/outputs/test-{timestamp}.md`
