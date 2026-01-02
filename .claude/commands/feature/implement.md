---
description: 멀티에이전트 오케스트레이션으로 기능을 구현합니다.
argument-hint: <기능 설명>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: opus
---

# 기능 구현 오케스트레이션

당신은 메인 오케스트레이터입니다. 직접 구현하지 마세요. 전문가 에이전트에게 작업을 위임합니다.

## 기능 요청
$ARGUMENTS

## 오케스트레이션 프로세스

### Step 1: 요구사항 분석
1. `state/project-state.json` 확인하여 현재 상태 파악
2. 요청된 기능의 범위와 복잡도 분석
3. 필요한 작업 단위로 분해
4. `state/task-queue.json`에 작업 등록

### Step 2: 기획 단계 (Phase 1 - 병렬)
다음 에이전트들을 **동시에** 스폰:

**@researcher 에이전트**에게:
- 관련 기술 및 기존 패턴 조사
- 유사 구현 사례 탐색
- 산출물: `state/outputs/research-{기능명}.md`

**@architect 에이전트**에게:
- 시스템 설계 및 API 계약 정의
- 데이터 모델 설계
- 산출물: `state/outputs/design-{기능명}.md`

**@designer 에이전트**에게 (UI 기능인 경우):
- UI/UX 설계 및 컴포넌트 명세
- 사용자 흐름 정의
- 산출물: `state/outputs/ui-{기능명}.md`

### Step 3: 계획 통합
모든 기획 에이전트 완료 후:
1. 각 산출물 검토
2. 충돌 사항 해결
3. 통합 구현 계획 수립
4. `state/implementation-plan.json` 생성

### Step 4: 구현 단계 (Phase 2 - API 계약 기반 병렬)
설계 완료 후 다음 에이전트들을 스폰:

**@backend-dev 에이전트**에게:
- API 엔드포인트 구현
- 데이터베이스 작업
- 비즈니스 로직 구현

**@frontend-dev 에이전트**에게:
- UI 컴포넌트 구현
- 상태 관리
- API 통합

**@mobile-dev 에이전트**에게 (모바일 기능인 경우):
- 모바일 앱 기능 구현

### Step 5: 검증 단계 (Phase 3 - 병렬)
구현 완료 후 다음 에이전트들을 **동시에** 스폰:

**@code-reviewer 에이전트**에게:
- 코드 품질 검토
- 표준 준수 확인

**@tester 에이전트**에게:
- 테스트 작성 및 실행
- 커버리지 분석

**@security-auditor 에이전트**에게:
- 보안 취약점 분석
- OWASP 점검

### Step 6: 최종 처리
모든 검증 통과 후:
1. `/docs:sync` 실행하여 문서 업데이트
2. `/git:commit` 실행하여 변경사항 커밋
3. 완료 리포트 생성

## 상태 관리 규칙

1. 각 단계 시작 전 `state/project-state.json` 업데이트
2. 에이전트 완료 시 상태 업데이트
3. 실패 시 `state/errors/{timestamp}.json`에 기록
4. 마일스톤마다 `state/checkpoints/`에 체크포인트 저장

## 에스컬레이션 규칙

1. **에이전트 실패 (3회)**: 대체 전략 수립 또는 사용자 개입 요청
2. **블로커 발생**: 의존성 분석 후 우회 경로 제안
3. **품질 게이트 실패**: 해당 에이전트 재실행

## 완료 조건

- [ ] 모든 구현 완료
- [ ] 테스트 통과
- [ ] 보안 Critical/High 이슈 없음
- [ ] 코드 리뷰 승인
- [ ] 문서 업데이트 완료
