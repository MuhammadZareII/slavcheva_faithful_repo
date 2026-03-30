# Reproduction protocol

## Objective
Reproduce the main result families reported in the paper:
1. gain saturation in a homogeneously broadened two-level slab waveguide,
2. population inversion relaxation to the theoretical saturation value,
3. noise-seeded coherent oscillation buildup in semiconductor microcavities,
4. steady-state lasing wavelength extraction,
5. relaxation oscillations and their spectral sidebands.

## Recommended order
### Stage 1 — Waveguide validation
Run:
```matlab
run('scripts/run_waveguide_validation.m')
```

Checks:
- electric field envelope initially grows and then saturates,
- population inversion relaxes from +1 toward a saturated value,
- the simulated trends agree qualitatively with the density-matrix formulas used in the paper.

### Stage 2 — 850 nm cavity
Run:
```matlab
run('scripts/run_vcsel_850nm_noise_seeded.m')
```

Checks:
- noise-seeded field buildup appears at the output facet,
- envelope develops damped oscillations,
- the expanded steady-state trace is nearly single-frequency.

### Stage 3 — 1.29 µm QW cavity
Run:
```matlab
run('scripts/run_vcsel_1290nm_qw_noise_seeded.m')
```

Checks:
- output facet field grows from the noise floor,
- relaxation oscillations are visible,
- FFT contains a dominant main line plus sidebands.

## Publication workflow
For any figure intended for a report or manuscript:
1. increase `cfg.solver.nz_per_wavelength`,
2. increase `cfg.solver.n_predictor_corrector`,
3. average cavity spectra over multiple seeds if linewidth smoothness is needed,
4. export using `mbfdtd1d_export_figure`.

## Validation criteria
The implementation should be regarded as successful if it reproduces:
- the qualitative regime transitions,
- the correct ordering of timescales,
- the approximate design wavelength,
- the saturation behavior,
- the existence of relaxation sidebands.

Exact curve overlap is a stronger target and may require parameter tuning.
