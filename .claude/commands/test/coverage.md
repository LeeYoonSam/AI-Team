---
description: 테스트 커버리지를 분석하고 개선점을 제안합니다.
allowed-tools: Bash, Read, Glob, Grep
model: haiku
---

# 커버리지 분석

## 커버리지 수집

### Node.js (Jest)
```bash
npm test -- --coverage --coverageReporters=json-summary
```

### Python (pytest)
```bash
pytest --cov=src --cov-report=json
```

## 분석 프로세스

### 1. 전체 커버리지 확인
- Lines (라인 커버리지)
- Branches (분기 커버리지)
- Functions (함수 커버리지)
- Statements (문장 커버리지)

### 2. 저커버리지 파일 식별
커버리지 80% 미만인 파일 목록 추출

### 3. 커버리지 갭 분석
- 테스트되지 않은 함수
- 테스트되지 않은 분기
- 복잡한 로직 중 테스트 누락

### 4. 우선순위 결정
- 비즈니스 크리티컬 로직
- 복잡도가 높은 코드
- 변경 빈도가 높은 코드

## 출력 형식

```markdown
# 커버리지 분석 리포트

## 전체 커버리지

| 구분 | 현재 | 목표 | 상태 |
|------|------|------|------|
| Lines | 85.2% | 80% | OK |
| Branches | 78.5% | 75% | OK |
| Functions | 92.1% | 85% | OK |
| Statements | 84.3% | 80% | OK |

## 저커버리지 파일 (< 80%)

| 파일 | 커버리지 | 우선순위 |
|------|---------|---------|
| src/utils/date.ts | 45% | 높음 |
| src/services/payment.ts | 62% | 높음 |
| src/helpers/format.ts | 70% | 중간 |

## 테스트 필요 영역

### 1. src/utils/date.ts (45%)
**누락된 함수**:
- `formatRelativeTime()` - 테스트 없음
- `parseCustomDate()` - 엣지 케이스 누락

**권장 테스트**:
- 다양한 날짜 형식 입력
- 타임존 처리
- 잘못된 입력 처리

### 2. src/services/payment.ts (62%)
**누락된 분기**:
- 결제 실패 케이스
- 부분 환불 로직

**권장 테스트**:
- 결제 실패 시나리오
- 환불 프로세스
- 동시성 처리

## 커버리지 개선 계획

| 단계 | 대상 | 예상 개선 |
|------|------|----------|
| 1 | date.ts | +35% |
| 2 | payment.ts | +18% |
| 3 | format.ts | +10% |

## 권장사항
1. 비즈니스 크리티컬 로직 우선 테스트
2. 엣지 케이스 테스트 추가
3. 통합 테스트 보강
```

## 산출물

**파일**: `state/outputs/coverage-{timestamp}.md`
