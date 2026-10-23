# 🌱 Greenhouse Frost Protection Window Controller — Video, Presentation & Documentation

This file collects the project demonstration video, presentation, and formal project documentation for the **Greenhouse Frost Protection Window Controller RTL-to-GDSII ASIC project**.

## 🎥 Project Demonstration Video

[**Open Greenhouse Frost Protection Controller Video**](https://docs.google.com/videos/d/15fk5YxGoNU6bVPsDC1_PgYOh33yX4XO94NfZpTmWxlI/edit?usp=drive_link)

## 📄 Project Documentation

[**Open Greenhouse Frost Protection Controller Project Documentation**](https://drive.google.com/file/d/1bLwvX9b5gG6UE0sdqHOTfeStcrH5RtG2/view?usp=sharing)

## 💻 Source Code and Repository

[**Open Greenhouse Frost Protection Controller GitHub Repository**](https://github.com/cpatilabhijith/GreenHouse_Frost_Controller)

The repository contains the project source and associated implementation files. Check the repository for the exact files currently available, including RTL, testbenches, synthesis scripts, constraints, timing scripts, gate-level simulation files, physical-design configuration, and reports.

## 📊 Project Presentation

[**Open Greenhouse Frost Protection Controller Presentation**](https://docs.google.com/presentation/d/1gOKZLKqz5x8Ed3it8nI9s9uulg1rqL9y/edit?usp=drive_link&ouid=106668357490989954010&rtpof=true&sd=true)


## 📝 Project Overview

The Greenhouse Frost Protection Window Controller is a digital control design written in Verilog RTL and intended for implementation using the SkyWater SKY130 standard-cell library, particularly `sky130_fd_sc_hd`.

The controller monitors a temperature input and generates control signals for opening or closing a greenhouse window. It includes threshold-based control with hysteresis, manual override inputs, and a frost alarm output.

### Main Features

- Temperature-based window open/close control.
- Hysteresis between closing and opening thresholds to reduce rapid switching.
- Manual open and manual close control.
- Frost alarm output for very low temperatures.
- RTL simulation and verification with a testbench.
- Standard-cell synthesis using Yosys and ABC.
- Static timing analysis using OpenSTA.
- Gate-level simulation using Icarus Verilog and SKY130 cell models.
- Physical-design implementation using OpenLane/OpenROAD.
- Layout and timing verification using generated reports and signoff checks.

## 🌡️ Control Behaviour

The project uses an encoded temperature input. In the current project convention, the encoded value is the temperature in degrees Celsius plus 40.

| Condition | Intended behaviour |
|---|---|
| Temperature at or below 2°C (`temp_value <= 42`) | Request window closing |
| Temperature at or above 5°C (`temp_value >= 45`) | Request window opening |
| Between the thresholds (`temp_value` 43–44) | Retain the previous window state |
| Temperature at or below 0°C (`temp_value <= 40`) | Assert the frost alarm |
| Manual close asserted | Give manual close priority |
| Manual open asserted without manual close | Request window opening |

Confirm these thresholds and input priorities against the current RTL and testbench before using this table as a final specification.

## 🧰 Tools and Technology

| Stage | Tool / technology |
|---|---|
| RTL design | Verilog |
| RTL simulation | Icarus Verilog (`iverilog`, `vvp`) |
| Logic synthesis | Yosys |
| Technology mapping | ABC and SKY130 standard-cell library |
| Timing constraints | SDC |
| Static timing analysis | OpenSTA |
| Gate-level simulation | Icarus Verilog with SKY130 simulation models |
| Physical design | OpenLane v0.21 / OpenROAD |
| Target process library | SKY130A, `sky130_fd_sc_hd` |
| Layout verification | DRC, LVS, antenna checks, and timing reports where configured |

## 🔄 RTL-to-GDSII Workflow

1. **RTL design:** Implement the controller logic in Verilog.
2. **RTL simulation:** Compile the RTL and testbench with Icarus Verilog and check the functional scenarios.
3. **Logic synthesis:** Run Yosys to optimize the design and map it to SKY130 standard cells using ABC and appropriate sequential-cell mapping.
4. **Pre-layout STA:** Analyze the mapped netlist using timing constraints and process-voltage-temperature (PVT) timing libraries.
5. **Gate-level simulation:** Simulate the mapped netlist with the appropriate SKY130 cell models and testbench.
6. **Physical design:** Use OpenLane/OpenROAD to perform floorplanning, placement, clock-tree synthesis where applicable, routing, and layout generation.
7. **Post-layout STA:** Analyze the implemented design using the appropriate routed netlist, timing constraints, and extracted parasitics.
8. **Final checks:** Review the generated GDSII, timing reports, DRC, LVS, and antenna-check results.

## 📂 Useful Project Areas

The repository may include directories or files for the following purposes:

- `rtl/` — Verilog RTL source.
- `tb/` — RTL testbench.
- `sim/rtl/` — RTL simulation output.
- `synthesis/` — synthesis scripts, logs, and mapped netlist.
- `constraints/` — timing constraints such as the SDC file.
- `timing/prelayout/` — pre-layout STA scripts and logs.
- `timing/postlayout/` — post-layout STA scripts and logs.
- `gls/` — gate-level simulation testbench and cell-model files.
- `openlane/` — physical-design configuration and run data.
- `reports/` — collected reports and analysis results.
- `results/gds/` — optional project-level copy of the final GDSII file.

This is a directory guide; check the current repository for the exact files and paths that are present.

## 📈 Results and Verification

Use the project’s generated logs and reports to document actual results for:

- RTL testbench pass/fail status.
- Synthesis cell statistics and mapped-netlist generation.
- Setup and hold timing across the PVT corners actually analyzed.
- Placement and routing completion.
- Final GDSII generation.
- DRC, LVS, and antenna-check outcomes.

Do not describe a check as passing unless the corresponding log or report confirms it. If timing analysis was run for only a subset of corners, state the number and names of those corners rather than claiming full multi-corner coverage.

## 🔐 Access Note

If a video, presentation, documentation, or repository link does not open, check that the relevant item is shared with the intended viewers and that they are signed in to an account with the required permission.
