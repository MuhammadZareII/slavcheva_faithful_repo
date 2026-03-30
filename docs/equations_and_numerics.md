# Equations and numerics

This repository follows the paper's 1-D semiclassical two-level Maxwell–Bloch model.

## State variables
- `Ex(z,t)` electric field
- `Hy(z,t)` magnetic field
- `rho1(z,t)` in-phase polarization component
- `rho2(z,t)` quadrature polarization component
- `rho3(z,t)` population difference

## Governing equations used
The implementation follows the standard real-vector two-level Maxwell–Bloch form consistent with the paper:

```text
d rho1 / dt = -rho1/T2 + omega0 * rho2
d rho2 / dt = -rho2/T2 - omega0 * rho1 + 2 * (gamma/hbar) * Ex * rho3
d rho3 / dt = -(rho3 - rho30)/T1 - 2 * (gamma/hbar) * Ex * rho2

d Ex / dt = -(1/eps) dHy/dz - (Na*gamma/(eps*T2))*rho1 + (Na*gamma*omega0/eps)*rho2 + noise/source
d Hy / dt = -(1/mu) dEx/dz
```

## Discretization
- 1-D Yee staggered grid
- leapfrog time stepping
- optional predictor-corrector loop coupling field and Bloch variables
- first-order Mur absorbing boundaries by default
- optional source injection:
  - smooth-switched CW sinusoid,
  - cavity white-Gaussian Langevin-like noise

## Noise model
The paper adds a random electric-field fluctuation term with Gaussian statistics.
This repo implements:
```text
E <- E + sigmaE * randn(...)
```
within the designated cavity region at each step.

## Why this implementation is stable-oriented
The published article states extremely fine spatial sampling and very small time steps.
This repo preserves the same modeling logic but exposes:
- CFL safety factor,
- predictor-corrector iterations,
- amplitude clipping / guardrails,
- optional output decimation,
so the solver can be used practically on a workstation.
