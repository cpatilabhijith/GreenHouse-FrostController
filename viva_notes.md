# Viva Notes - Greenhouse Frost Protection Window Controller

Q1. What is the real-world problem?
Greenhouse vents left open during sudden temperature drops cause frost damage
to plants. Manual monitoring overnight is impractical. A dedicated hardware
controller is fast, reliable, and fails safe.

Q2. Why a dedicated circuit and not a microcontroller?
Low latency, no software/firmware, no OS, no cloud, no boot time, deterministic
fail-safe behaviour, and lower power. The chip does one thing only: control a
vent window from a temperature code.

Q3. What is the sequential logic in the design?
A 3-state FSM with a 2-bit state register (two sky130_fd_sc_hd__dfxtp_1
flip-flops). States: S_IDLE (00), S_OPEN (01), S_CLOSED (10).

Q4. Why hysteresis and how is it implemented?
Without hysteresis the window would chatter near the threshold. Hysteresis:
close only when temp <= 2 C; open only when temp >= 5 C; hold previous state
in between. This hold is why sequential logic is mandatory.

Q5. What was the hardest bug you fixed?
RTL Test 1 initially failed because the combinational output block was not
gated by reset. During reset, temperature was still driving outputs. Fix:
wrap the whole combinational block in if (reset) ... else ...

Q6. What happened during gate-level simulation?
Two tests produced status=xx. Root cause: SKY130 dfxtp UDP has a hold-check
that fires the notifier when Q->D feedback arrives inside the FF hold window.
Fix: functional-only FF model for GLS; timing verified by STA.

Q7. How do you prove timing is safe if GLS ignores hold checks?
By Static Timing Analysis (pre-layout and post-layout), across all 16 PVT
corners with actual routed SPEF. Worst hold +0.19 ns, worst setup +44.01 ns
on a 50 ns clock.

Q8. Why 50 ns clock period?
10x slower than the intrinsic critical path (~1 ns). Massive margin, easy
timing closure, matches the Hz-rate temperature sensor update.

Q9. Why only 27 cells in a 100x100 um die (3.4%)?
Die area is fixed by the project constraint; the design is small. Extra area
is used for routing, taps, decoupling, and fill.

---
Q10. Difference between pre-layout and post-layout STA?
Pre-layout: net delays estimated/ideal. Post-layout: delays from extracted
SPEF (actual routed RC). Post-layout is sign-off.

Q11. Did you use AI? How do you know you understand the design?
Yes for drafts. Every line was reviewed, tested, debugged. When Test 1 failed
we identified the missing reset gating. When RePlAce diverged we traced it to
PL_TARGET_DENSITY = 0.5 vs actual 3.4% utilisation. All fixes were
evidence-driven.

Q12. What is the die area?
100 x 100 um = 10,000 um^2. Confirmed from DEF:
DIEAREA ( 0 0 ) ( 100000 100000 ) in 1000-DBU/um units.

Q13. Difference between synthesis.v, synthesis_optimized.v, synthesis_cts.v,
synthesis_preroute.v?
- synthesis.v: Yosys output, no physical cells
- synthesis_optimized.v: post-resizer
- synthesis_cts.v: post clock-tree synthesis
- synthesis_preroute.v: the netlist routed by TritonRoute; used for post-layout STA

Q14. Why "core area too small for power grid"?
Standard PDN pitch (153 um) > 100 um die. OpenLane minimises the grid.
Flow still completes.

Q15. Significance of LVS "no net, device, pin, or property mismatches"?
Layout netlist is logically identical to schematic netlist. Every wire, pin,
and transistor matches. Strongest proof the physical design implements the RTL.

---

Numbers to Remember

Die size:               100 um x 100 um = 0.01 mm^2
Core area:              88.96 um x 78.24 um
Total cells:            27
Flip-flops:             2 (sky130_fd_sc_hd__dfxtp_1)
Chip area (cells only): 221.46 um^2
Utilisation:            3.44 %
Clock period:           50 ns (20 MHz)
Worst setup slack:      +44.01 ns (ss_n40C_1v28)
Worst hold slack:       +0.19 ns (ff_n40C_1v95)
DRC violations:         0
LVS errors:             0
Antenna violations:     0
CVC errors:             0
TritonRoute violations: 0
GDS size:               228,896 bytes
Total runtime:          1 min 42 sec

---

One-sentence summary

I designed a 3-state sequential FSM in Verilog, verified it with RTL and
gate-level simulation (10/10 passing), synthesised it to 27 SKY130 standard
cells, closed timing across all 16 PVT corners both pre-layout and post-layout
with extracted parasitics, ran the full OpenLane physical design flow inside
the 100 x 100 um die, and produced a DRC-clean, LVS-clean GDSII.
