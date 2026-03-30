addpath(genpath('src'));

% Fully fast mode for laptop iteration. Disable for higher-fidelity passes.
QUICK_MODE = true;

cfg = mbfdtd1d_defaults();
cfg = mbfdtd1d_profile_vcsel1290(cfg);

if QUICK_MODE
    cfg.runtime.t_end = min(cfg.runtime.t_end, 8.0e-12);
    cfg.runtime.snapshot_time = min(7.0e-12, 0.85 * cfg.runtime.t_end);
    cfg.runtime.store_every = max(cfg.runtime.store_every, 40);
    cfg.grid.nz_per_wavelength = 60;
    cfg.solver.n_predictor_corrector = 2;
    cfg.runtime.cfl_safety = 0.88;
    cfg.export.png_dpi = 180;
    fprintf('run_vcsel_1290nm_qw_noise_seeded: QUICK_MODE enabled for faster turnaround.');
end

cfg = mbfdtd1d_profile_vcsel1290(cfg);
if QUICK_MODE
    cfg.runtime.t_end = 8.0e-12;
    cfg.runtime.snapshot_time = 7.0e-12;
    cfg.runtime.store_every = max(cfg.runtime.store_every, 40);
    cfg.solver.n_predictor_corrector = 2;
    cfg.runtime.cfl_safety = 0.88;
    cfg.export.png_dpi = 180;
end

out = mbfdtd1d_main(cfg);

if ~exist(cfg.export.out_dir, 'dir')
    mkdir(cfg.export.out_dir);
end

n_eff = max(out.material.n(out.material.is_cavity));
env_cycles = 6;
if QUICK_MODE
    env_cycles = 4;
end
env = mbfdtd1d_smooth_envelope(out.time, out.probe_Ex, cfg.physics.lambda0, n_eff, env_cycles);

%% Buildup trace (envelope, publication-friendly)
fig = figure('Color', 'w');
plot(out.time * 1e12, env, 'LineWidth', 1.2);
xlabel('time [ps]');
ylabel('|E_x| envelope [V/m]');
title('1.29 \mum cavity: noise-seeded coherent oscillation buildup');
mbfdtd1d_publication_style(gca);
mbfdtd1d_export_figure(fig, fullfile(cfg.export.out_dir, 'vcsel1290_buildup'), cfg.export.png_dpi);

%% Steady-state zoom
N = numel(out.time);
i0 = max(1, round(cfg.observation.steady_state_start_fraction * N));
fig = figure('Color', 'w');
plot(out.time(i0:end) * 1e12, out.probe_Ex(i0:end), 'LineWidth', 0.9);
xlabel('time [ps]');
ylabel('E_x [V/m]');
title('1.29 \mum cavity: steady-state zoom');
mbfdtd1d_publication_style(gca);
mbfdtd1d_export_figure(fig, fullfile(cfg.export.out_dir, 'vcsel1290_steady_state_zoom'), cfg.export.png_dpi);

%% Spatial profile
fig = figure('Color', 'w');
yyaxis left;
plot(out.z * 1e6, out.snapshot.Ex, 'LineWidth', 1.2);
ylabel('E_x [V/m]');
yyaxis right;
plot(out.z * 1e6, out.snapshot.rho3, '--', 'LineWidth', 1.2);
ylabel('\rho_3');
xlabel('z [\mum]');
title('1.29 \mum cavity: spatial field / inversion profile');
mbfdtd1d_publication_style(gca);
mbfdtd1d_export_figure(fig, fullfile(cfg.export.out_dir, 'vcsel1290_spatial_profile'), cfg.export.png_dpi);

%% FFT spectrum
fft_fraction = cfg.observation.fft_start_fraction;
j0 = max(1, round(fft_fraction * N));
spec = mbfdtd1d_fft_spectrum(out.time(j0:end), out.probe_Ex(j0:end), cfg.observation.fft_window);

valid = spec.valid_lambda;
if ~isempty(cfg.observation.fft_lambda_limits_um)
    lims_m = sort(cfg.observation.fft_lambda_limits_um(:)).' * 1e-6;
    valid = valid & spec.lambda >= lims_m(1) & spec.lambda <= lims_m(2);
end

fig = figure('Color', 'w');
plot(spec.lambda(valid) * 1e6, spec.power(valid), 'LineWidth', 1.0);
set(gca, 'XDir', 'reverse');
if ~isempty(cfg.observation.fft_lambda_limits_um)
    xlim(sort(cfg.observation.fft_lambda_limits_um, 'ascend'));
end
xlabel('\lambda [\mum]');
ylabel('spectral power [a.u.]');
title('1.29 \mum cavity: FFT spectrum');
mbfdtd1d_publication_style(gca);
mbfdtd1d_export_figure(fig, fullfile(cfg.export.out_dir, 'vcsel1290_fft_spectrum'), cfg.export.png_dpi);

save(fullfile(cfg.export.out_dir, 'vcsel1290_noise_seeded.mat'), 'cfg', 'out', 'env', 'spec');
disp('1.29 um cavity run completed.');
