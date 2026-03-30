function cfg = mbfdtd1d_profile_waveguide(cfg)
%MBFDTD1D_PROFILE_WAVEGUIDE 15 um long slab gain-medium validation case.

cfg.case_name = 'waveguide_validation';
cfg.physics.lambda0 = 1.50e-6;
cfg.physics.omega0  = 2*pi*cfg.constants.c0/cfg.physics.lambda0;
cfg.physics.Na      = 1e24;
cfg.physics.T1      = 10e-12;
cfg.physics.T2      = 10e-15;

Lbuf = 3e-6;
Lg   = 9e-6;
cfg.grid.Lz = Lbuf + Lg + Lbuf;

lambda_medium = cfg.physics.lambda0 / 1.0;
dz = lambda_medium / cfg.grid.nz_per_wavelength;
Nz = floor(cfg.grid.Lz / dz) + 1;
z = linspace(cfg.grid.z0, cfg.grid.z0 + cfg.grid.Lz, Nz);

n = ones(size(z));
is_gain = (z >= Lbuf) & (z <= Lbuf + Lg);
rho30 = cfg.physics.rho30_abs * ones(size(z));
rho30(is_gain) = cfg.physics.rho30_gain;

cfg.grid.Nz = Nz;
cfg.grid.z  = z;
cfg.grid.dz = z(2)-z(1);

cfg.material.n = n;
cfg.material.eps_r = n.^2;
cfg.material.is_gain = is_gain;
cfg.material.is_cavity = false(size(z));
cfg.material.is_qw = false(size(z));
cfg.material.rho30 = rho30;

cfg.source.mode = 'cw';
cfg.source.amplitude = 5e7;
cfg.source.position_index = 6;
cfg.observation.probe_index = find(z > (Lbuf + Lg + 1e-6), 1, 'first');
cfg.runtime.t_end = 15e-12;
cfg.runtime.snapshot_time = 12e-12;
end
