# Greenhouse Frost Protection Window Controller
## SKY130 RTL-to-GDSII ASIC Design Project

A compact sequential digital controller that monitors greenhouse temperature
and automatically drives a vent/window motor to prevent frost damage to plants.
Designed, verified, and taken to a verified GDSII layout on the SkyWater SKY130
130 nm process, targeting a 100 um x 100 um die.

---

## 1. Real-World Application

Greenhouse vents left open during sudden temperature drops let cold air enter
and cause frost damage to crops. Manual monitoring overnight is impractical.
Simple thermostats chatter and wear out the vent motor. A dedicated hardware
controller responds instantly and reliably, with no software, cloud, or OS
dependency.

Users: greenhouse growers, nurseries, hobbyist gardeners.
Where: embedded in an automated greenhouse vent controller.

---

## 2. Functional Specification

| Condition                  | Action                           |
|----------------------------|----------------------------------|
| temp_value <= 42  (<= 2 C) | Close window                     |
| temp_value >= 45  (>= 5 C) | Open window                      |
| 43 - 44 (2-5 C dead-band)  | Hold previous state (hysteresis) |
| temp_value <= 40  (<= 0 C) | Assert frost alarm               |
| manual_close = 1           | Force close (overrides auto)     |
| manual_open = 1            | Force open (if no manual close)  |
| reset = 1                  | All outputs forced to 0 (safe)   |

Temperature encoding: temp_value = actual_temperature_C + 40, unsigned 8-bit.

Motor interlock: window_motor_open and window_motor_close are never both 1.

status[1:0]: 00 = idle, 01 = closing, 10 = opening.

---
## 3. RTL Interface

Inputs  (13 pins): clk, reset, temp_value[7:0], manual_open, manual_close
Outputs  (4 pins): window_motor_close, window_motor_open, frost_alarm, status[1:0]

---

## 4. Sequential Logic

- 3-state FSM: S_IDLE (00), S_OPEN (01), S_CLOSED (10)
- State register: 2 D flip-flops (sky130_fd_sc_hd__dfxtp_1)
- Combinational: comparators, next-state logic, output decoder
- No counters, no memories, no latches

---

## 5. Verification Summary

### 5.1 RTL Simulation (Icarus Verilog 10.1)
- 10 self-checking test cases
- Result: 10 / 10 PASSED

### 5.2 Yosys Synthesis
- Target: sky130_fd_sc_hd high-density cells
- Result: 27 cells, chip area ~221 um^2, 2 flip-flops, 0 latches

### 5.3 Pre-Layout STA (OpenSTA, all 16 corners)
- Worst setup: +44.02 ns (ss_n40C_1v28) on a 50 ns clock
- Worst hold:  +0.19 ns (ff_n40C_1v95)
- All corners: PASS

### 5.4 Gate-Level Simulation (Icarus + SKY130 UDP models)
- Functional-only FF model used (standard practice - timing verified by STA)
- Result: 10 / 10 PASSED

### 5.5 OpenLane Physical Design (v0.21)
- Die area: 100 um x 100 um
- Core area: 88.96 um x 78.24 um
- Total runtime: 1 min 42 sec
- Final cell count: 27
- Fill cells: 55, Tap cells: 90, Endcaps: 56

| Check                    | Result |
|--------------------------|--------|
| TritonRoute violations   | 0      |
| Short violations         | 0      |
| Metal spacing violations | 0      |
| Off-grid violations      | 0      |
| Magic DRC                | 0      |
| Antenna violations       | 0      |
| LVS errors               | 0      |
| CVC errors               | 0      |

### 5.6 Post-Layout STA (OpenSTA, all 16 corners, with SPEF)
- Worst setup: +44.01 ns (ss_n40C_1v28)
- Worst hold:  +0.19 ns (ff_n40C_1v95)
- All corners: PASS

### 5.7 Pre vs Post-Layout Delta
- Setup delta: -0.150 ns to +0.020 ns
- Hold delta:  -0.010 ns to +0.230 ns

---
## 6. Final Deliverables

| Artifact          | Path                                                    |
|-------------------|---------------------------------------------------------|
| GDSII (KLayout)   | results/greenhouse_frost_controller.gds                 |
| GDSII (Magic)     | results/greenhouse_frost_controller.magic.gds           |
| SPEF              | results/greenhouse_frost_controller.spef                |
| Routed netlist    | results/greenhouse_frost_controller.synthesis_preroute.v|
| Flow summary      | results/final_summary_report.csv                        |
| Pre-layout STA    | timing/prelayout/*.log                                  |
| Post-layout STA   | timing/postlayout/*.log                                 |
| Pre-vs-post table | timing/comparison.txt                                   |
| RTL               | rtl/greenhouse_frost_controller.v                       |
| Testbench         | tb/greenhouse_frost_controller_tb.v                     |

---

## 7. Design Decisions and Trade-offs

| Decision                | Reason                                                 |
|-------------------------|--------------------------------------------------------|
| 3-state FSM (not 5)     | 5 states need movement timers and more area            |
| 2-bit state encoding    | Minimum flops for 3 states                             |
| Reset gating of outputs | Guarantees deterministic safe outputs during reset     |
| Functional FF for GLS   | Sky130 UDP hold-check causes false X; STA covers timing|
| FP_CORE_UTIL=30         | Design is 3.4% of core; leaves room for routing        |
| PL_TARGET_DENSITY=0.10  | Near actual utilisation; prevents RePlAce divergence   |
| PL_BASIC_PLACEMENT=1    | Robust for very small designs in a large die           |

---

## 8. Known Limitations

- temp_value is assumed to come from an external ADC/comparator.
- No debounce on manual_open / manual_close.
- No window-position feedback - command-based.
- Only manual_close has priority when both manual inputs are asserted.

---
## 9. Reproducing the Flow

1. RTL simulation:
   iverilog -g2012 -o tb.vvp rtl/*.v tb/*.v && vvp tb.vvp

2. Synthesis:
   yosys -l synth.log synth.ys

3. Pre-layout STA:
   OpenSTA with SDC over 16 SKY130 corners

4. Gate-level simulation:
   iverilog -g2012 -DSKY130_FD_SC_HD__DFXTP_1_V with functional FF override

5. Physical design:
   OpenLane v0.21 in Docker, DIE_AREA = 0 0 100 100, PDK = sky130A

6. Post-layout STA:
   OpenSTA with SPEF over 16 SKY130 corners

---

## 10. Viva Quick Reference

See viva_notes.md for anticipated questions and prepared answers.
