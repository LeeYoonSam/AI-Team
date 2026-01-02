---
description: 새 프로젝트를 멀티에이전트 시스템으로 초기화합니다.
argument-hint: [프로젝트 유형: web|mobile|api|fullstack]
allowed-tools: Bash, Write, Read, Glob
model: sonnet
---

# 프로젝트 초기화

프로젝트 유형: $ARGUMENTS

## 초기화 단계

### 1. Git 초기화
- git init (이미 되어있으면 스킵)
- .gitignore 확인 및 생성

### 2. 디렉토리 구조 확인
다음 디렉토리가 존재하는지 확인하고 없으면 생성:
- .claude/agents/
- .claude/commands/
- .claude/skills/
- state/agents/
- state/checkpoints/
- state/outputs/
- docs/
- scripts/
- templates/

### 3. 설정 파일 확인
다음 파일이 존재하는지 확인:
- CLAUDE.md
- .claude/settings.json
- .gitignore

### 4. Git Hooks 설치
scripts/setup.sh 실행하여 Git Hooks 설치

### 5. 초기 상태 파일 생성
- state/project-state.json 초기화
- state/task-queue.json 초기화

### 6. 프로젝트 유형별 추가 설정

#### web
- 프론트엔드 중심 설정
- React/Next.js 템플릿

#### mobile
- React Native/Flutter 설정
- iOS/Android 디렉토리 구조

#### api
- 백엔드 중심 설정
- API 문서 템플릿

#### fullstack
- 프론트엔드 + 백엔드 설정
- 모노레포 구조

## 완료 메시지

초기화 완료 후 다음 정보 출력:
- 생성된 디렉토리 목록
- 생성된 파일 목록
- 다음 단계 안내
