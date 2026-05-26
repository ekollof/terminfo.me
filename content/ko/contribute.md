---
title: "기여하기"
description: "GitHub를 통해 새로운 terminfo 항목을 컬렉션에 제출하는 방법."
---

## 새로운 terminfo 항목 기여 방법

시스템 ncurses 데이터베이스에 없는 터미널이나 더 나은/완전한 정의를 가진 터미널을 위한 고품질 terminfo 소스 파일을 환영합니다.

**언어 참고:** 이슈 설명, 풀 리퀘스트, 댓글은 영어로 작성해 주세요. 이는 유지보수자가 기여를 효율적으로 검토하는 데 도움이 됩니다.

### 빠른 시작 (추천)

가장 쉬운 방법은 **먼저 이슈를 여는 것**입니다:

→ **[GitHub 이슈를 통해 새로운 terminfo 제출](https://github.com/ekollof/terminfo.me/issues/new?template=new-terminfo.yml)**

이렇게 하면 PR을 열기 전에 항목을 검토하고 피드백을 받을 수 있습니다.

---

### 수동 프로세스 (숙련된 기여자용)

직접 PR을 열고 싶다면 다음 단계를 따르세요:

#### 1. `.ti` 파일 생성

`static/terminfo/<terminal-name>.ti`에 다음 헤더 형식으로 새 파일을 만드세요:

```text
# -----------------------------------------------------------------------------
# Terminal: <terminal-name>
# Source:   <공식 소스 또는 문서 URL>
# License:  <예: MIT, Public Domain, GPL-2.0>
# Notes:    <특별한 주의사항 또는 경고>
# -----------------------------------------------------------------------------
```

예시:

```text
# -----------------------------------------------------------------------------
# Terminal: ghostty
# Source:   https://github.com/ghostty-org/ghostty
# License:  MIT
# Notes:    Ghostty 터미널 에뮬레이터 (2025+)
# -----------------------------------------------------------------------------
ghostty|Ghostty 터미널 에뮬레이터,
    ...
```

#### 2. 로컬에서 파일 검증

```bash
# 구문 검사
tic -x static/terminfo/your-terminal.ti

# 전체 검증 스위트 실행
contrib/run-all-checks.sh
```

#### 3. 체크섬 업데이트

```bash
sha256sum static/terminfo/your-terminal.ti >> static/terminfo/checksums.txt
```

또는 pre-commit 훅이 대신 하도록 하세요 (추천):

```bash
# 일회성 설정
cp contrib/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

#### 4. Pull Request 열기

- 브랜치 생성: `git checkout -b add-your-terminal`
- 변경 사항 커밋 (pre-commit 훅이 도와줍니다)
- 명확한 설명과 함께 PR 열기

---

### 좋은 기여란?

- 항목은 **반드시** `tic -x`로 깨끗하게 컴파일되어야 합니다
- **권위 있는** 항목을 우선시하세요 (터미널 프로젝트 자체에서 온 것)
- 가능한 한 많은 최신 기능을 포함하세요 (`XT`, `Tc`, `Su`, kitty 키보드 프로토콜 등)
- 헤더에 소스를 명확히 문서화하세요

### 행동 강령

존중하고 건설적으로 행동해 주세요. 터미널 에뮬레이터는 빠르게 발전합니다 — 우리 모두가 원격 터미널 생활을 모두에게 더 좋게 만들기 위해 노력하고 있습니다.

질문이 있으신가요? 이슈를 열거나 PR에서 멘션해 주세요.
