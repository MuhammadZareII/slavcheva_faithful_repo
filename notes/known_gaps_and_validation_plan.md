# Known gaps and validation plan

## Known gaps
1. The paper does not give a complete code listing.
2. Supplementary tuning details are not available here.
3. Exact hardware/runtime setup from the original work is not replicated.
4. The original implementation may have used stronger parallelization and more aggressive discretization than typical laptop runs.

## Validation plan
### Minimal validation
- Waveguide gain saturation curve exists and saturates.
- Population inversion relaxes toward the expected analytical value.
- Noise-seeded cavity case builds coherent output.
- FFT has a dominant main line at the designed wavelength region.

### Stronger validation
- Mesh refinement study.
- Seed-to-seed robustness study.
- Relaxation oscillation frequency extraction.
- Sideband spacing comparison.
- Wavelength drift vs. discretization analysis.

## Release language recommendation
Use wording such as:
> “Research-grade reproduction implementation based on the published equations and reported parameter sets.”

Avoid wording such as:
> “Original authors' exact simulator.”
