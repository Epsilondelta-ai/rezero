[English](../README.md) | **한국어** | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop는 **Re:Zero − Starting Life in Another World**의 **사망회귀**에서 영감을 받은 에이전트 워크플로우입니다.

Subaru가 작업을 구현하고, 일곱 마녀가 독립적으로 검토하며, 실패 기억을 보존한 채 `HEAD`에서 재시도합니다.

## 목차

- [설치](#설치)
  - [Pi](#pi)
  - [Claude Code](#claude-code)
  - [Codex](#codex)
- [사용법](#사용법)
- [워크플로우](#워크플로우)
- [스킬](#스킬)
- [컨셉](#컨셉)
  - [나츠키 스바루](#나츠키-스바루)
  - [사망회귀](#사망회귀)
  - [일곱 마녀](#일곱-마녀)
  - [렘](#렘)
- [라이선스](#라이선스)

## 설치

### Pi

```bash
pi install git:github.com/epsilondelta-ai/rezero
```

로컬 개발:

```bash
pi install /path/to/rezero
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

이후 `/plugins`에서 `rezero`를 설치하고 새 세션을 시작합니다.

## 사용법

Pi, Claude Code, Codex에서:

```text
/rezero init
/rezero <task>
```

`/rezero`는 init 상태(`.rezero/tools.md` marker + `.rezero/memory/` ignore)를 확인하고, 없으면 init을 먼저 자동 실행합니다.

## 워크플로우

1. **오케스트레이션** — `/rezero`가 `rezero`를 로드합니다. 큰 요청은 `rezero-plan`이 done 기준이 있는 작은 태스크로 나눕니다. 독립 태스크는 subagent/team agent로 병렬 실행할 수 있습니다.
2. **구현** — Subaru가 현재 `HEAD`에서 순차 태스크 하나 또는 병렬 태스크 그룹 하나를 수행합니다. 병렬 그룹은 먼저 병합한 뒤 하나의 결과로 검증합니다.
3. **평가** — `rezero-witches`가 일곱 마녀를 병렬 호출합니다. 마녀는 확증편향을 피하기 위해 Subaru 컨텍스트를 이어받지 않습니다. 결과는 `witch | verdict | reason | evidence` 테이블로 표시됩니다.
4. **사망회귀** — `fail` 하나라도 있으면 `.rezero/memory/subaru-deaths.md`에 최소 실패 기억을 기록하고 `git reset --hard HEAD && git clean -fd` 후 재시도합니다.
5. **통과** — `pass`/`warning`만 있으면 warning은 `.rezero/memory/rem.md`에 저장하고 accepted route를 커밋합니다. 커밋 후 death memory는 삭제합니다.
6. **렘** — Rem warning도 일반 Re:ZERO attempt처럼 구현 → 검증 → 마녀 평가 → fail 없을 때 커밋합니다. 모두 해결되면 `rem.md`를 삭제합니다.

## 스킬

- `rezero-init` — setup witch evaluation tools.
- `rezero` — `/rezero` 엔트리포인트.
- `rezero-plan` — 큰 요청을 작은 ordered tasks로 분해.
- `rezero-subaru` — Subaru의 단일 태스크 구현 루프.
- `rezero-witches` — fresh-context 일곱 마녀 평가와 verdict table.
- `rezero-rem` — warning memory 저장/해결/삭제.

## 언어와 이름

지원 언어에서는 사용자 언어로 답하고, 마녀 verdict와 병렬 구현 에이전트 이름도 해당 언어 표기를 사용합니다. 미지원 언어는 영어로 fallback합니다.

| Type | Names |
| --- | --- |
| Witches | 에키드나, 티폰, 미네르바, 다프네, 카밀라, 세크메트, 사테라 |
| Parallel implementers | 베아트리스, 에밀리아, 람, 가필, 율리우스 |

## 컨셉

### 나츠키 스바루

Subaru는 구현자입니다. 현재 `HEAD`에서 시작해 구현/검증하고, 실패하면 같은 실패를 반복하지 않을 기억만 남깁니다.

### 사망회귀

![Natsuki Subaru](./images/subaru.webp)

```bash
git reset --hard HEAD
git clean -fd
```

코드는 죽고, 교훈은 살아남습니다.

### 일곱 마녀

![Witches' Tea Party](./images/witches-tea-party.webp)

| 마녀 | 초점 | 예시 도구 |
| --- | --- | --- |
| 에키드나 | 완전성, 엣지케이스, 커버리지 | SonarQube, coverage, Stryker |
| 티폰 | 계약, 명세, 공개 인터페이스 | typecheck, linter, Spectral, Pact |
| 미네르바 | 사용자 피해, 회귀, 런타임 실패 | tests, Playwright, Lighthouse CI, k6 |
| 다프네 | 의존성/자원 소비 | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| 카밀라 | UI/문서/이름/증명의 기만 | screenshots, axe, lychee |
| 세크메트 | 유지보수성, dead code, 중복 | SonarQube, Knip, jscpd |
| 사테라 | 통합, 보안, 정책, 일관성 | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### 렘

![Rem](./images/rem.webp)

Rem은 warning memory입니다. 통과한 warning은 `.rezero/memory/rem.md`에 남고, 해결/재평가/커밋될 때까지 유지됩니다.

## 라이선스

이 프로젝트는 [MIT License](../LICENSE)에 따라 배포됩니다.
