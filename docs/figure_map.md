# Figure map

## Paper result families vs repository scripts

### Gain saturation
- Script: `scripts/run_waveguide_validation.m`
- Outputs:
  - `waveguide_envelopes.pdf`
  - `waveguide_population_relaxation.pdf`
  - `waveguide_spatial_snapshot.pdf`

### 850 nm microcavity
- Script: `scripts/run_vcsel_850nm_noise_seeded.m`
- Outputs:
  - `vcsel850_buildup.pdf`
  - `vcsel850_steady_state_zoom.pdf`
  - `vcsel850_spatial_profile.pdf`

### 1.29 µm microcavity / QW case
- Script: `scripts/run_vcsel_1290nm_qw_noise_seeded.m`
- Outputs:
  - `vcsel1290_buildup.pdf`
  - `vcsel1290_steady_state_zoom.pdf`
  - `vcsel1290_spatial_profile.pdf`
  - `vcsel1290_fft_spectrum.pdf`

## Style
All figures use the shared publication style helper:
- white background,
- serif-like label defaults,
- consistent line widths,
- vector export to PDF,
- high-resolution PNG sidecars.
