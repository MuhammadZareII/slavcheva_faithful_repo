function smoke_test_profiles()
addpath(genpath('src'));

cfg = mbfdtd1d_defaults();
cfg = mbfdtd1d_profile_waveguide(cfg);
assert(isfield(cfg.material, 'n'));
assert(numel(cfg.material.n) == cfg.grid.Nz);

cfg = mbfdtd1d_defaults();
cfg = mbfdtd1d_profile_vcsel850(cfg);
assert(any(cfg.material.is_cavity));
assert(any(cfg.material.is_gain));

cfg = mbfdtd1d_defaults();
cfg = mbfdtd1d_profile_vcsel1290(cfg);
assert(any(cfg.material.is_qw));

disp('smoke_test_profiles passed');
end
