---
description: Pull Request를 생성합니다.
argument-hint: [PR 제목]
allowed-tools: Bash, Read, Glob
model: sonnet
---

# Pull Request 생성

## PR 제목
$ARGUMENTS

## 프로세스

### 1. 현재 브랜치 확인
```bash
git branch --show-current
git log --oneline main..HEAD
```

### 2. 변경 사항 분석
```bash
git diff main...HEAD --stat
git diff main...HEAD
```

### 3. PR 정보 수집

**커밋 히스토리**:
```bash
git log --oneline main..HEAD
```

**변경된 파일**:
```bash
git diff main...HEAD --name-only
```

### 4. PR 본문 작성

```markdown
## 요약
{변경 사항 요약}

## 변경 내용
- {변경 1}
- {변경 2}
- {변경 3}

## 테스트
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 수동 테스트 완료

## 체크리스트
- [ ] 코드 리뷰 완료
- [ ] 문서 업데이트
- [ ] 보안 점검

## 스크린샷 (해당시)
{스크린샷}

## 관련 이슈
Closes #{이슈번호}
```

### 5. PR 생성

```bash
gh pr create \
  --title "{제목}" \
  --body "{본문}" \
  --base main \
  --head {현재브랜치}
```

## PR 제목 규칙

### 형식
```
[type] 간단한 설명
```

### 타입
- `[Feature]`: 새로운 기능
- `[Fix]`: 버그 수정
- `[Docs]`: 문서 업데이트
- `[Refactor]`: 리팩토링
- `[Test]`: 테스트 추가

### 예시
- `[Feature] 사용자 인증 기능 추가`
- `[Fix] 로그인 오류 수정`
- `[Docs] API 문서 업데이트`

## 출력

PR 생성 완료 후:
- PR URL
- PR 번호
- 리뷰어 할당 안내
