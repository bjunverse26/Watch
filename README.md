# Watch

SystemVerilog로 구현한 FPGA 디지털 시계 프로젝트입니다. 입력 클럭을 기준으로 1초 tick을 만들고, 초/분/시 카운터를 연결해 `00:00:00`부터 `23:59:59`까지 순환하는 watch RTL을 구성합니다.

## 프로젝트 개요

이 프로젝트는 시계 동작을 단계적으로 구현한 RTL과 Vivado 시뮬레이션용 테스트벤치를 포함합니다.

- `one_sec_gen`: 입력 클럭을 `i_freq` 값만큼 분주해 1초 tick 생성
- `tick_gen`: 입력 tick을 받아 N진 카운터 값과 carry tick 생성
- `top_watch_v1`: 초/분/시 카운터를 직접 작성한 초기 버전
- `top_watch_v2`: `tick_gen`을 재사용해 초/분/시를 모듈식으로 연결한 개선 버전
- `tb_one_sec_gen`, `tb_top_watch`: 분주기와 전체 시계 동작 검증용 테스트벤치

## 주요 기능

| 구분 | 내용 |
| --- | --- |
| 구현 언어 | SystemVerilog |
| 주요 모듈 | `one_sec_gen`, `tick_gen`, `top_watch_v1`, `top_watch_v2` |
| 기본 시계 범위 | 24-hour format, `00:00:00` ~ `23:59:59` |
| 시간 단위 | 초 0~59, 분 0~59, 시 0~23 |
| 제어 입력 | `reset`, `i_run_en`, `i_freq` |
| 출력 | `o_sec`, `o_min`, `o_hour` |
| 검증 | Vivado/XSim 테스트벤치 |

## 동작 구조

### 1. 1초 tick 생성

`rtl/one_sec_gen.sv`는 `i_run_en`이 활성화되어 있을 때 내부 카운터를 증가시키고, 카운터가 `i_freq - 1`에 도달하면 한 클럭 폭의 `o_sec_tick`을 발생시킵니다.

```systemverilog
if (r_counter == i_freq - 1) begin
    r_counter <= '0;
    o_sec_tick <= 1'b1;
end
```

실제 보드에서 `100 MHz` 클럭을 1초로 나누려면 `i_freq`를 `100_000_000`으로 둘 수 있고, 테스트벤치에서는 빠른 시뮬레이션을 위해 `10` 또는 `100`처럼 작은 값을 사용합니다.

### 2. tick 기반 카운터

`rtl/tick_gen.sv`는 `i_tick`이 들어올 때마다 값을 증가시키고, `INPUT_TICK - 1`에 도달하면 값을 0으로 되돌리면서 다음 단위로 넘길 `o_tick`을 한 클럭 동안 출력합니다.

- 초 카운터: `INPUT_TICK = 60`
- 분 카운터: `INPUT_TICK = 60`
- 시 카운터: `INPUT_TICK = 24`

`DELAY` 파라미터는 출력 값 `o_val`을 지정한 클럭 수만큼 지연시켜 carry tick과 표시 값의 타이밍을 맞추기 위해 사용됩니다.

### 3. 최상위 watch 모듈

`rtl/top_watch_v2.sv`는 다음 순서로 모듈을 연결합니다.

```text
clk, i_freq
   |
   v
one_sec_gen -> sec_tick
   |
   v
tick_gen(60) -> minute_tick, o_sec
   |
   v
tick_gen(60) -> hour_tick, o_min
   |
   v
tick_gen(24) -> o_hour
```

현재 Vivado 구현 산출물과 테스트벤치는 `top_watch_v2`를 중심으로 구성되어 있습니다.

## 주요 파일

| 경로 | 설명 |
| --- | --- |
| `rtl/one_sec_gen.sv` | 입력 클럭을 기준으로 1초 tick을 만드는 분주기 |
| `rtl/tick_gen.sv` | 재사용 가능한 N진 tick 카운터 |
| `rtl/top_watch_v1.sv` | 초/분/시 카운터를 직접 구현한 초기 watch 모듈 |
| `rtl/top_watch_v2.sv` | `tick_gen`을 연결한 모듈식 watch 최상위 모듈 |
| `tb/tb_one_sec_gen.sv` | `one_sec_gen` 단위 테스트벤치 |
| `tb/tb_top_watch.sv` | `top_watch_v2` 전체 동작 테스트벤치 |
| `constraints/top.xdc` | Vivado 클럭 및 false path 제약 |
| `sim/` | Vivado 프로젝트와 시뮬레이션/구현 산출물 |

## 프로젝트 구조

```text
Watch/
+-- constraints/
|   +-- top.xdc
+-- rtl/
|   +-- one_sec_gen.sv
|   +-- tick_gen.sv
|   +-- top_watch_v1.sv
|   +-- top_watch_v2.sv
+-- tb/
|   +-- tb_one_sec_gen.sv
|   +-- tb_top_watch.sv
+-- sim/
|   +-- sim.xpr
|   +-- ...
+-- .gitignore
+-- LICENSE
+-- README.md
```
