function cfg = mbfdtd1d_profile_vcsel1290(cfg)
%MBFDTD1D_PROFILE_VCSEL1290 Approximate 1.29 um QW cavity profile.
%
% Paper-faithful intent: bottom 20.5 AlAs / GaAs pairs, top 19 pairs,
% 5-lambda cavity, and 6 quantum wells embedded in the cavity.

cfg.case_name = 'vcsel1290_qw_noise_seeded';
cfg.physics.lambda0 = 1.29e-6;
cfg.physics.omega0  = 2*pi*cfg.constants.c0/cfg.physics.lambda0;
cfg.physics.Na      = 1e24;
cfg.physics.gamma   = 4.8e-28;
cfg.physics.T1      = 10e-12;
cfg.physics.T2      = 70e-15;

lambda0 = cfg.physics.lambda0;
n_hi = 3.40;
n_lo = 2.95;
n_out = 1.0;

n_pairs_bottom = 20;
n_pairs_top    = 19;
L_cavity = 5*lambda0/n_hi;
n_qw = 6;
qw_w = 8e-9;

layers_n = [];
layers_d = [];

% 20.5 bottom pairs -> 20 full pairs + high-index quarter-wave cap.
for k = 1:n_pairs_bottom
    layers_n = [layers_n, n_hi, n_lo]; %#ok<AGROW>
    layers_d = [layers_d, lambda0/(4*n_hi), lambda0/(4*n_lo)]; %#ok<AGROW>
end
layers_n = [layers_n, n_hi]; %#ok<AGROW>
layers_d = [layers_d, lambda0/(4*n_hi)]; %#ok<AGROW>

layers_n = [layers_n, n_hi]; %#ok<AGROW>
layers_d = [layers_d, L_cavity]; %#ok<AGROW>

for k = 1:n_pairs_top
    layers_n = [layers_n, n_lo, n_hi]; %#ok<AGROW>
    layers_d = [layers_d, lambda0/(4*n_lo), lambda0/(4*n_hi)]; %#ok<AGROW>
end

L_left_air  = 2.0e-6;
L_right_air = 2.0e-6;
L_core = sum(layers_d);
cfg.grid.Lz = L_left_air + L_core + L_right_air;

dz = lambda0 / (max([n_hi, n_lo, n_out]) * cfg.grid.nz_per_wavelength);
Nz = floor(cfg.grid.Lz / dz) + 1;
z = linspace(0, cfg.grid.Lz, Nz);

n = n_out * ones(size(z));
is_cavity = false(size(z));
is_gain   = false(size(z));
is_qw     = false(size(z));
rho30     = cfg.physics.rho30_abs * ones(size(z));

cursor = L_left_air;
z_cavity_start = NaN;
z_cavity_end   = NaN;
for idx = 1:numel(layers_n)
    mask = (z >= cursor) & (z < cursor + layers_d(idx));
    n(mask) = layers_n(idx);
    if idx == numel(layers_n) - 2*n_pairs_top
        z_cavity_start = cursor;
        z_cavity_end = cursor + layers_d(idx);
    end
    cursor = cursor + layers_d(idx);
end
is_cavity = (z >= z_cavity_start) & (z <= z_cavity_end);

qw_centers = linspace(z_cavity_start + 0.15*L_cavity, z_cavity_end - 0.15*L_cavity, n_qw);
for k = 1:numel(qw_centers)
    mask = abs(z - qw_centers(k)) <= qw_w/2;
    is_qw(mask) = true;
    is_gain(mask) = true;
end
rho30(is_qw) = cfg.physics.rho30_gain;

cfg.grid.Nz = Nz;
cfg.grid.z  = z;
cfg.grid.dz = z(2)-z(1);

cfg.material.n = n;
cfg.material.eps_r = n.^2;
cfg.material.is_gain = is_gain;
cfg.material.is_cavity = is_cavity;
cfg.material.is_qw = is_qw;
cfg.material.rho30 = rho30;

cfg.source.mode = 'noise';
cfg.source.noise_sigma = 1e-3;
cfg.source.position_index = [];
cfg.observation.probe_index = max(2, Nz - round(0.6e-6 / cfg.grid.dz));
cfg.observation.fft_lambda_limits_um = [1.20, 1.50];
cfg.runtime.t_end = 18e-12;
cfg.runtime.snapshot_time = 8e-12;
end
