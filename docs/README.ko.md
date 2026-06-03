[English](../README.md) | **한국어** | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

> Re:ZERO Loop는 **Re: 제로부터 시작하는 이세계 생활**의 **사망회귀**에서 영감을 받은 에이전트 워크플로우입니다.

![](./images/rezero.webp)

## 설치

### Pi

```bash
pi install npm:rezero
```

### Claude Code

```bash
/plugin marketplace add epsilondelta-ai/rezero
/plugin install rezero@rezero-marketplace
```

### Codex

```bash
codex plugin marketplace add epsilondelta-ai/rezero
```

*이후 `/plugins`에서 `rezero`를 설치하고 새 세션을 시작합니다.*

## 사용법

Pi, Claude Code, Codex에서:

```text
/rezero <task>
```

`/rezero`는 init 상태(`.rezero/tools.md` marker + `.rezero/memory/` ignore)를 확인하고, 없으면 init을 먼저 자동 실행합니다.

## 사망회귀 BGM

Re:ZERO Loop가 사망회귀를 실행하면 기본적으로 `assets/bgm.mp3`를 재생합니다.

현재 프로젝트에서 끄려면 `/rezero bgm false` 또는 `/rezero bgm off`를 사용합니다:

```text
/rezero bgm false
/rezero bgm off
```

다시 켜려면 `/rezero bgm true` 또는 `/rezero bgm on`을 사용합니다:

```text
/rezero bgm true
/rezero bgm on
```

이 명령들은 `.rezero/memory/config.json`을 씁니다:

```json
{
  "bgm": false
}
```

한 번의 실행 또는 셸 프로필에서 끄려면:

```bash
export REZERO_BGM_DISABLE=1
```

## 워크플로우

1. 우리는 스바루에게 시련을 내립니다.
2. 스바루는 시련을 이겨내기 위해 노력을 합니다.
3. 허나, 언제나 그랬듯 실패하여 사망회귀를 할 수 있습니다.  
   여기서 조금은 어색하긴 하지만, 일곱 마녀가 스바루의 운명을 판단합니다.  
   일곱 마녀는 각자의 지표를 가지고 스바루의 운명을 판단합니다. [여기서](#일곱-마녀) 어떤 지표로 판단하는지 확인할 수 있습니다.
4. 스바루의 노력이 실패로 돌아가 사망회귀를 하게 되면 일곱 마녀의 평가를 `.rezero/memory/subaru-deaths.md`에 기억합니다.(저 파일은 gitignore 에 포함되어 리셋되지 않습니다.)  
   그 후 `git reset --hard HEAD`, `git clean -fd` 를 하여 사망회귀를 하게 됩니다.
5. 스바루는 이 시련을 이겨낼 때 까지 위의 과정을 반복하게 됩니다. `.rezero/memory/subaru-deaths.md` `.rezero/memory/rem.md` 파일을 삭제합니다.
6. 시련을 이겨내 사망회귀의 체크포인트가 갱신되었지만, 마녀들이 warning 으로 평가한 항목이 있다면 `.rezero/memory/rem.md` 에 기록합니다.
7. 스바루는 렘을 구하기 위해 다시 위의 여정을 떠나게 됩니다.
8. 내려진 시련을 이겨내고, 렘을 구하는데 성공했다면 스바루는 오랜만에 휴식을 하게 됩니다.

## 컨셉

### 사망회귀

![스바루](./images/subaru.webp)
```bash
git reset --hard HEAD
git clean -fd
```

스바루의 사망회귀에서 영감을 받았습니다.  
이미 지저분한 코드의 위에서 지저분한 컨텍스트를 가지고 제대로 할 수 있을 것인가에 대한 의문에서 이 개념을 차용하게 되었습니다.

### 일곱 마녀

![Witches' Tea Party](./images/witches-tea-party.webp)

일곱 마녀가 스바루의 운명을 판단하는건 원작의 팬으로서 조금 어색하게 느껴지기도 하지만,  
여러 관점에서 평가를 내린다는 것은 꽤나 괜찮은 아이디어이기에 차용하게 되었습니다.

| 마녀 | 초점 | 예시 도구 |
| --- | --- | --- |
| 에키드나 | 완전성, 엣지케이스, 커버리지 | 셀프 호스팅 SonarQube, coverage, Stryker |
| 티폰 | 계약, 명세, 공개 인터페이스 | typecheck, linter, Spectral, Pact |
| 미네르바 | 사용자 피해, 회귀, 런타임 실패 | tests, Playwright, Lighthouse CI, k6 |
| 다프네 | 의존성/자원 소비 | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| 카밀라 | UI/문서/이름/증명의 기만 | screenshots, axe, lychee |
| 세크메트 | 유지보수성, dead code, 중복 | 셀프 호스팅 SonarQube, Knip, jscpd |
| 사테라 | 통합, 보안, 정책, 일관성 | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### 렘 (스포일러 주의)

![Rem](./images/rem.webp)

원작에서 스바루가 여정을 떠나는 가장 주된 이유입니다.  
렘을 구하기 위해서죠.

원작에서도 백경 토벌전을 성공해서 체크포인트가 갱신되었지만  
렘은 폭식의 대죄주교에게 존재를 먹혀 깨어나지 못하게 됩니다.

이 점에 영감을 받아 체크포인트가 갱신되었지만  
warning 이 있다면 그것을 렘으로 보면 어떨까 하는 생각을 하게 되었습니다.

## 라이선스

이 프로젝트는 [MIT License](../LICENSE)에 따라 배포됩니다.
