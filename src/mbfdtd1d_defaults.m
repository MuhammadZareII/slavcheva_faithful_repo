function cfg = mbfdtd1d_defaults()
%MBFDTD1D_DEFAULTS Shared defaults for all reproduction cases.
%
% This repository targets a paper-faithful but configurable implementation.
% The defaults are intentionally conservative and are expected to be tuned
% per case.

cfg.constants.c0   = 299792458;
cfg.constants.eps0 = 8.854187817e-12;
cfg.constants.mu0  = 4*pi*1e-7;
cfg.constants.hbar = 1.054571817e-34;

cfg.case_name = 'unset';

cfg.physics.lambda0 = 1.50e-6;
cfg.physics.omega0  = 2*pi*cfg.constants.c0/cfg.physics.lambda0;
cfg.physics.gamma   = 4.8e-28;      % dipole coupling coefficient [C m]
cfg.physics.Na      = 1e24;         % resonant dipole density [m^-3]
cfg.physics.T1      = 10e-12;       % longitudinal relaxation
cfg.physics.T2      = 10e-15;       % transverse relaxation
cfg.physics.rho30_gain = +1.0;
cfg.physics.rho30_abs  = -1.0;

cfg.grid.Lz = 15e-6;
cfg.grid.z0 = 0.0;
cfg.grid.nz_per_wavelength = 160;
cfg.grid.Nz = [];

cfg.runtime.t_end = 8e-12;
cfg.runtime.cfl_safety = 0.80;
cfg.runtime.store_every = 20;
cfg.runtime.snapshot_time = [];
cfg.runtime.rng_seed = 1234;

cfg.solver.n_predictor_corrector = 4;
cfg.solver.use_mur_abc = true;
cfg.solver.clip_rho3 = true;
cfg.solver.rho3_clip_value = 1.5;

cfg.source.mode = 'cw';      % 'cw', 'noise', 'none'
cfg.source.position_index = [];
cfg.source.amplitude = 5e7;
cfg.source.ramp_cycles = 5;
cfg.source.noise_sigma = 1e-3;     % [V/m], paper-style order
cfg.source.noise_only_in_cavity = true;

cfg.observation.probe_index = [];
cfg.observation.fft_start_fraction = 0.70;
cfg.observation.steady_state_start_fraction = 0.80;
cfg.observation.fft_window = 'hann';
cfg.observation.fft_lambda_limits_um = [];

repo_root = fileparts(fileparts(mfilename('fullpath')));
cfg.export.out_dir = fullfile(repo_root, 'figures', 'generated');
cfg.export.png_dpi = 300;

% Placeholders to be filled by profile builders.
cfg.material.n = [];
cfg.material.eps_r = [];
cfg.material.is_gain = [];
cfg.material.is_cavity = [];
cfg.material.is_qw = [];
cfg.material.rho30 = [];
end
