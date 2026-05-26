---
title: "설치 스크립트"
description: "install.sh 동반 스크립트의 작동 방식과 안전한 사용 방법."
---

## install.sh

우리는 `$TERM`을 감지하고, 일치하는 `.ti` 소스 파일을 다운로드한 후 `tic -x`로 컴파일하여 `~/.terminfo`에 설치하는 잘 주석이 달린 멱등성 Bash 스크립트를 제공합니다.

### 빠른 사용법

```bash
curl -fsSL https://terminfo.me/install.sh | sh
```

### 명시적 터미널 이름 지정

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- alacritty
```

### 체크섬 검증

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- --verify
```

### 스크립트가 하는 일

1. **자체 검증**: 자신과 `install.json`의 최신 복사본을 다운로드하고 자신의 SHA-256을 검증한 후 검증된 복사본을 다시 실행합니다 (`--skip-self-check`를 사용하지 않는 한).
2. `$TERM` 환경 변수를 감지합니다.
3. 이 컬렉션의 `.ti` 파일에 매핑합니다.
4. HTTPS를 통해 소스 파일을 다운로드합니다.
5. 필요 시 terminfo 파일의 SHA-256 체크섬을 검증합니다.
6. `tic -x -o ~/.terminfo <file.ti>`를 실행합니다.
7. 항목이 이미 존재하고 최신인 경우 재설치를 건너뜁니다.

### 자체 검증

스크립트는 다른 작업을 수행하기 전에 자체 검사를 수행합니다:

- 서버에서 `install.sh`와 `install.json`의 최신 복사본을 다운로드합니다.
- 다운로드한 스크립트의 SHA-256이 `install.json`에 게시된 값과 일치하는지 확인합니다.
- 일치하면 검증된 복사본을 다시 실행하고 계속 진행합니다.
- 일치하지 않거나 다운로드에 실패하면 스크립트는 오류와 함께 중단됩니다.

이 기능은 서버의 `install.sh` 파일(또는 캐시)이 변조된 경우 사용자를 보호합니다.

`--skip-self-check`로 자체 검사를 우회할 수 있습니다 (권장하지 않음).

### 안전성

- 스크립트는 **절대** `sudo`나 상승된 권한으로 `tic`를 실행하지 않습니다.
- 홈 디렉토리의 `~/.terminfo`에만 씁니다.
- terminfo 항목이 없으면 명확한 오류 메시지와 함께 정상적으로 실패합니다.
- `sh`로 파이핑하기 전에 언제든지 스크립트를 검사할 수 있습니다.

[GitHub에서 install.sh 소스 보기](https://github.com/ekollof/terminfo.me/blob/main/static/install.sh)
