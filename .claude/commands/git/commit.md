---
description: 변경된 파일을 자동으로 커밋합니다.
argument-hint: [커밋 메시지]
allowed-tools: Bash, Read, Glob
model: haiku
---

# 자동 Git 커밋

## 커밋 메시지
$ARGUMENTS

## 프로세스

### 1. 현재 상태 확인
```bash
git status --short
```

### 2. 최근 커밋 스타일 참조
```bash
git log --oneline -5
```

### 3. 변경 내용 분석
```bash
git diff --staged --stat
git diff --stat
```

### 4. 커밋 메시지 생성

사용자가 메시지를 제공한 경우: 해당 메시지 사용

제공하지 않은 경우 변경 내용 기반 자동 생성:
- `feat`: 새로운 기능
- `fix`: 버그 수정
- `docs`: 문서 변경
- `style`: 코드 스타일 변경
- `refactor`: 리팩토링
- `test`: 테스트 추가/수정
- `chore`: 기타 변경

### 5. 스테이징 및 커밋

```bash
# 변경된 파일 스테이징
git add -A

# 제외할 파일 언스테이징
git reset -- state/agents/*.json
git reset -- state/checkpoints/*.json
git reset -- *.log

# 커밋
git commit -m "{type}: {message}"
```

## 커밋 메시지 규칙

### 형식
```
<type>: <subject>

[optional body]

[optional footer]
```

### 타입
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 수정
- `style`: 코드 포맷팅
- `refactor`: 코드 리팩토링
- `test`: 테스트 코드
- `chore`: 빌드, 패키지 등

### 규칙
- 첫 줄: 50자 이내
- 본문: 72자 줄바꿈
- 한국어로 작성
- 현재형 사용

## 제외 파일

자동으로 제외되는 파일:
- `state/agents/*.json` (에이전트 상태)
- `state/checkpoints/*.json` (체크포인트)
- `*.log` (로그 파일)
- `.DS_Store`, `Thumbs.db` (OS 파일)

## 출력

커밋 완료 후:
- 커밋 해시
- 변경된 파일 수
- 추가/삭제된 라인 수
