# Paper-faithful MATLAB reproduction repository
**Target paper:** G. M. Slavcheva, J. M. Arnold, and R. W. Ziolkowski, *FDTD Simulation of the Nonlinear Gain Dynamics in Active Optical Waveguides and Semiconductor Microcavities*, IEEE JSTQE 10(5), 2004.

This repository is a **best-effort, paper-faithful MATLAB implementation** of the 1-D full-wave Maxwell–Bloch / FDTD model described in the paper, including the Langevin noise extension used for spontaneous-emission-seeded lasing.

## What is included
- A modular MATLAB implementation of the **1-D Yee FDTD + Maxwell–Bloch** solver.
- Configurations for:
  - slab gain-medium validation,
  - 850 nm semiconductor microcavity,
  - 1.29 µm semiconductor microcavity with quantum wells.
- Figure generation scripts intended to recreate the paper's main result families:
  - gain saturation,
  - population-inversion relaxation,
  - cavity field buildup,
  - steady-state oscillations,
  - spatial field / inversion profiles,
  - FFT spectrum and linewidth sidebands.
- Internal notes with derivation details and implementation decisions.

## Important scope note
This repository was prepared from the **main paper text only**. It is therefore designed to be **paper-faithful**, but not to claim perfect byte-for-byte reproduction of the authors' original unpublished implementation.

In practice, exact numerical overlays may still depend on:
- discretization details not fully specified in the article,
- predictor-corrector iteration details,
- boundary-condition implementation nuances,
- random seed / noise realization,
- hardware-dependent floating-point effects,
- any parameters that may have been tuned in the original code but not fully reported.

So this repo should be understood as:

> **A professional, research-grade reproduction framework based directly on the paper**  
> rather than  
> **a guarantee of exact historical source-code replication**.

## Repository layout
```text
src/
  mbfdtd1d_main.m               core solver
  mbfdtd1d_defaults.m           defaults shared across cases
  mbfdtd1d_profile_waveguide.m  slab waveguide profile
  mbfdtd1d_profile_vcsel850.m   850 nm cavity profile
  mbfdtd1d_profile_vcsel1290.m  1.29 µm cavity profile
  mbfdtd1d_apply_source.m       continuous-wave / noise source injection
  mbfdtd1d_envelope.m           envelope extraction helper
  mbfdtd1d_fft_spectrum.m       FFT spectrum helper
  mbfdtd1d_publication_style.m  figure styling
  mbfdtd1d_export_figure.m      vector + raster export helper

scripts/
  run_waveguide_validation.m
  run_vcsel_850nm_noise_seeded.m
  run_vcsel_1290nm_qw_noise_seeded.m
  make_all_figures.m

docs/
  reproduction_protocol.md
  equations_and_numerics.md
  figure_map.md

notes/
  internal_extended_notes.md
  known_gaps_and_validation_plan.md

tests/
  smoke_test_profiles.m
  smoke_test_solver_configuration.m
```

## Quick start
Open MATLAB in the repository root and run:

```matlab
addpath(genpath('src'));
run('scripts/run_waveguide_validation.m');
run('scripts/run_vcsel_850nm_noise_seeded.m');
run('scripts/run_vcsel_1290nm_qw_noise_seeded.m');
```

To generate all publication-style figures:

```matlab
run('scripts/make_all_figures.m');
```

Figures are exported to:

```text
figures/generated/
```

## MATLAB version
Designed for modern MATLAB releases (R2021b+ recommended).  
No toolbox is strictly required beyond base MATLAB.

## Recommended workflow for publication-quality reproduction
1. Run the **waveguide validation** first.
2. Confirm the saturation trend and population relaxation.
3. Run the **850 nm cavity** case.
4. Run the **1.29 µm QW cavity** case.
5. Compare wavelength, buildup time, relaxation oscillations, and FFT sidebands.
6. Tune only:
   - spatial resolution,
   - time step safety factor,
   - number of predictor-corrector iterations,
   - random seed averaging,
   - observation window for FFT.

## Citation
If you use this repository in your own work, cite the original paper first.

## License
MIT License (repository implementation only; does not apply to the original paper).


## Fast package
This package ships with `QUICK_MODE = true` in the waveguide, 850 nm, and 1.29 um scripts so all three cases run faster for debugging and plotting. Switch those flags to `false` when you want slower, higher-fidelity passes.
