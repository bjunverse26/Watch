# Watch

## 프로젝트 개요

Watch는 FPGA 클럭을 기준으로 1초 tick을 생성하고, 초/분/시 카운터를 연결해 `00:00:00`부터 `23:59:59`까지 순환하는 24시간 시계 RTL 프로젝트입니다. `TopWatchV2`는 재사용 가능한 `TickGen` 모듈을 계층적으로 연결해 rollover 동작을 단순하게 검증할 수 있도록 구성했습니다.

## 주요 특징

- programmable divisor 기반 1초 tick 생성
- 초, 분, 시를 동일한 modulo counter 구조로 구현
- `i_run_en`으로 시계 진행과 정지 제어
- `TopWatchV1` 직접 counter 구현과 `TopWatchV2` 모듈형 구현 제공
- interface, task, checker 기반 self-checking 테스트벤치 제공

## 상세 스펙

| 항목 | 내용 |
| --- | --- |
| 시간 형식 | 24-hour format |
| 표시 범위 | `00:00:00` ~ `23:59:59` |
| 주요 입력 | `i_clk`, `i_reset`, `i_freq`, `i_run_en` |
| 주요 출력 | `o_sec`, `o_min`, `o_hour` |
| Tick 생성 | `OneSecGen` |
| Counter 생성 | `TickGen` |
| Top RTL | `rtl/TopWatchV2.sv` |
| 테스트벤치 | `tb/TbOneSecGen.sv`, `tb/TbTopWatch.sv` |

## 검증 결과 요약

- `OneSecGen` 테스트벤치에서 programmable divisor 기준 tick 발생 간격 자동 확인
- `TopWatchV2` 테스트벤치에서 1초, 1분, 1시간 진행 및 pause 유지 동작 자동 확인
- 작은 `i_freq` 값을 사용해 긴 board-frequency 시뮬레이션 없이 rollover 시나리오 검증 가능
