---
description: 특정 문서를 수동으로 업데이트합니다.
argument-hint: <문서 이름 또는 경로>
allowed-tools: Read, Write, Edit, Glob, Grep
model: sonnet
---

# 문서 업데이트

## 대상 문서
$ARGUMENTS

## 업데이트 프로세스

### 1. 문서 식별

문서 이름으로 경로 매핑:
- `architecture` → `docs/architecture.md`
- `agents` → `docs/agents.md`
- `workflows` → `docs/workflows.md`
- `state` → `docs/state-management.md`
- `automation` → `docs/automation.md`
- `getting-started` → `docs/getting-started.md`

### 2. 현재 상태 분석

**관련 코드/설정 확인**:
- 문서와 관련된 소스 파일 검색
- 최신 변경사항 파악
- 불일치 항목 식별

### 3. 문서 업데이트

**업데이트 영역**:
- 목차 갱신
- 본문 내용 업데이트
- 코드 예시 갱신
- 다이어그램 업데이트

### 4. 변경 이력 추가

문서 하단에 변경 이력 추가:
```markdown
## 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| {오늘} | {변경 요약} | AI Agent |
```

## 문서별 업데이트 가이드

### architecture.md
- 시스템 구성도 확인
- 새 컴포넌트 추가
- 기술 스택 정보 갱신

### agents.md
- 에이전트 목록 테이블
- 역할 및 책임 설명
- 모델 및 도구 정보

### workflows.md
- 슬래시 커맨드 목록
- 워크플로우 다이어그램
- 사용 예시

### state-management.md
- 상태 파일 구조
- 상태 값 설명
- 복구 절차

### automation.md
- Git Hooks 설명
- 자동화 스크립트
- 설정 방법

### getting-started.md
- 설치 단계
- 초기 설정
- 기본 사용법

## 출력

업데이트 완료 후:
- 변경된 섹션 목록
- 변경 요약
- 검증 필요 항목
