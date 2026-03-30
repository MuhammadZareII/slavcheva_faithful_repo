function cfg = mbfdtd1d_profile_vcsel850(cfg)
%MBFDTD1D_PROFILE_VCSEL850 Approximate 850 nm DBR cavity profile.
%
% Paper-faithful intent: bottom 35.5 AlAs / AlGaAs pairs, top 5 oxide /
% AlGaAs pairs, and a gain-filled Fabry-Perot cavity.

cfg.case_name = 'vcsel850_noise_seeded';
cfg.physics.lambda0 = 0.85e-6;
cfg.physics.omega0  = 2*pi*cfg.constants.c0/cfg.physics.lambda0;
cfg.physics.Na      = 1e24;
cfg.physics.gamma   = 4.8e-28;
cfg.physics.T1      = 1e-9;
cfg.physics.T2      = 10e-15;

lambda0 = cfg.physics.lambda0;
n_hi = 3.2736;   % Al0.3Ga0.7As gain medium
n_lo_bottom = 2.95;  % AlAs-like effective index for bottom DBR
n_lo_top    = 1.55;  % oxidized mirror approximation
n_out = 1.0;

n_pairs_bottom = 35;
n_pairs_top    = 5;
L_cavity = lambda0 / n_hi;

layers_n = [];
layers_d = [];

% 35.5 bottom pairs -> 35 full pairs + high-index quarter-wave cap.
for k = 1:n_pairs_bottom
    layers_n = [layers_n, n_hi, n_lo_bottom]; %#ok<AGROW>
    layers_d = [layers_d, lambda0/(4*n_hi), lambda0/(4*n_lo_bottom)]; %#ok<AGROW>
end
layers_n = [layers_n, n_hi]; %#ok<AGROW>
layers_d = [layers_d, lambda0/(4*n_hi)]; %#ok<AGROW>

% Gain-filled Fabry-Perot cavity.
layers_n = [layers_n, n_hi]; %#ok<AGROW>
layers_d = [layers_d, L_cavity]; %#ok<AGROW>

% Top mirror: 5 oxide / AlGaAs pairs.
for k = 1:n_pairs_top
    layers_n = [layers_n, n_lo_top, n_hi]; %#ok<AGROW>
    layers_d = [layers_d, lambda0/(4*n_lo_top), lambda0/(4*n_hi)]; %#ok<AGROW>
end

L_left_air  = 1.0e-6;
L_right_air = 1.0e-6;
L_core = sum(layers_d);
cfg.grid.Lz = L_left_air + L_core + L_right_air;

dz = lambda0 / (max([n_hi, n_lo_bottom, n_lo_top, n_out]) * cfg.grid.nz_per_wavelength);
Nz = floor(cfg.grid.Lz / dz) + 1;
z = linspace(0, cfg.grid.Lz, Nz);

n = n_out * ones(size(z));
is_cavity = false(size(z));
is_gain   = false(size(z));
rho30     = cfg.physics.rho30_abs * ones(size(z));

cursor = L_left_air;
cavity_start = NaN;
cavity_end   = NaN;
for idx = 1:numel(layers_n)
    mask = (z >= cursor) & (z < cursor + layers_d(idx));
    n(mask) = layers_n(idx);
    if idx == numel(layers_n) - 2*n_pairs_top
        cavity_start = cursor;
        cavity_end = cursor + layers_d(idx);
    end
    cursor = cursor + layers_d(idx);
end

cavity_mask = (z >= cavity_start) & (z <= cavity_end);
is_cavity(cavity_mask) = true;
is_gain(cavity_mask) = true;
rho30(cavity_mask) = cfg.physics.rho30_gain;

cfg.grid.Nz = Nz;
cfg.grid.z  = z;
cfg.grid.dz = z(2)-z(1);

cfg.material.n = n;
cfg.material.eps_r = n.^2;
cfg.material.is_gain = is_gain;
cfg.material.is_cavity = is_cavity;
cfg.material.is_qw = false(size(z));
cfg.material.rho30 = rho30;

cfg.source.mode = 'noise';
cfg.source.noise_sigma = 1e-3;
cfg.source.position_index = [];
cfg.observation.probe_index = max(2, Nz - round(0.4e-6 / cfg.grid.dz));
cfg.observation.fft_lambda_limits_um = [0.80, 0.95];
cfg.runtime.t_end = 12e-12;
cfg.runtime.snapshot_time = 8e-12;
end
