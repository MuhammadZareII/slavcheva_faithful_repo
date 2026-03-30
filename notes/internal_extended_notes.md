# Internal extended notes

## 1. Intent of this repository
The purpose is not to produce a toy pedagogical code. It is to provide a repository that:
- reads as serious research software,
- is easy to audit,
- can be placed on GitHub without embarrassment,
- is structured so later upgrades are straightforward.

## 2. Where the implementation is intentionally conservative
The article's exposition is strong on physical formulation but not fully source-code-level detailed. Therefore the following are exposed as configurable:
- predictor-corrector iterations,
- source placement,
- Mur ABC,
- FFT windowing,
- output decimation.

This is intentional. A rigid hard-coded implementation would look “paper-faithful” on the surface while being harder to validate.

## 3. Why 1-D only
The paper discusses full-wave vectorial FDTD but the actual examples reproduced here are organized as 1-D structures, which is enough for:
- slab gain validation,
- DBR / cavity field buildup studies,
- wavelength and linewidth estimation from output traces.

## 4. Boundary conditions
The article refers to exact one-way wave-equation based transmitting boundaries.
This repository uses a robust Mur-style absorbing boundary by default for transparency and simplicity.
If exact historical boundary matching becomes critical, the boundary module is the first place to refine.

## 5. Random-noise reproducibility
Every cavity run stores:
- seed,
- sigmaE,
- noise region,
- FFT window.
That makes result provenance much cleaner when figures are regenerated.

## 6. Publication note
For a journal submission or a public release that claims quantitative reproduction, the following should be done:
1. benchmark against the waveguide saturation formulas,
2. perform time-step and spatial-step convergence,
3. verify cavity wavelength convergence versus mesh density,
4. average spectral outputs across seeds where appropriate,
5. document every departure from the paper's wording.

## 7. Suggested next upgrades
- exact boundary scheme matching the earlier Ziolkowski references,
- optional pump dynamics,
- cavity-seed ensemble sweeps,
- automatic figure panels matching the paper layout,
- YAML/JSON experiment manifests,
- CI smoke tests via MATLAB batch mode.
