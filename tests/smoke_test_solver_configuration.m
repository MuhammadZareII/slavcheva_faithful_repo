function smoke_test_solver_configuration()
addpath(genpath('src'));

cfg = mbfdtd1d_defaults();
cfg = mbfdtd1d_profile_waveguide(cfg);
cfg.runtime.t_end = 0.25e-12;
cfg.runtime.store_every = 10;
cfg.solver.n_predictor_corrector = 1;

out = mbfdtd1d_main(cfg);

assert(isfield(out, 'time'));
assert(isfield(out, 'probe_Ex'));
assert(isfield(out, 'snapshot'));
assert(~isempty(out.time));

disp('smoke_test_solver_configuration passed');
end
