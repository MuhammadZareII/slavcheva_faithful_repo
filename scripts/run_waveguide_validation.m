addpath(genpath('src'));

% Fully fast mode for laptop iteration. Disable for higher-fidelity passes.
QUICK_MODE = true;

cfg = mbfdtd1d_defaults();
cfg = mbfdtd1d_profile_waveguide(cfg);

if QUICK_MODE
    cfg.runtime.t_end = min(cfg.runtime.t_end, 6.0e-12);
    cfg.runtime.snapshot_time = min(5.0e-12, 0.8 * cfg.runtime.t_end);
    cfg.runtime.store_every = max(cfg.runtime.store_every, 20);
    cfg.grid.nz_per_wavelength = 48;
    cfg.solver.n_predictor_corrector = 1;
    cfg.runtime.cfl_safety = 0.90;
    cfg.export.png_dpi = 180;
    fprintf('run_waveguide_validation: QUICK_MODE enabled for faster turnaround.\n');
end

cfg = mbfdtd1d_profile_waveguide(cfg);
if QUICK_MODE
    cfg.runtime.t_end = 6.0e-12;
    cfg.runtime.snapshot_time = 5.0e-12;
    cfg.runtime.store_every = max(cfg.runtime.store_every, 20);
    cfg.solver.n_predictor_corrector = 1;
    cfg.runtime.cfl_safety = 0.90;
    cfg.export.png_dpi = 180;
end

% Multi-amplitude sweep similar to the paper's validation section.
E0_list = [5.0e6, 2.0e7, 5.0e7, 1.0e8];
results = cell(size(E0_list));
envs = cell(size(E0_list));

env_cycles = 6;
if QUICK_MODE
    env_cycles = 4;
end

for k = 1:numel(E0_list)
    cfgk = cfg;
    cfgk.source.amplitude = E0_list(k);
    cfgk.runtime.rng_seed = 100 + k;
    results{k} = mbfdtd1d_main(cfgk);
    envs{k} = mbfdtd1d_smooth_envelope(results{k}.time, results{k}.probe_Ex, cfgk.physics.lambda0, 1.0, env_cycles);
end

if ~exist(cfg.export.out_dir, 'dir')
    mkdir(cfg.export.out_dir);
end

%% Envelope comparison
fig = figure('Color', 'w');
hold on;
for k = 1:numel(results)
    envk = envs{k};
    max_envk = max(envk);
    if max_envk <= 0
        envk = zeros(size(envk));
    else
        envk = envk ./ max_envk;
    end
    plot(results{k}.time * 1e15, envk, 'LineWidth', 1.4, ...
        'DisplayName', sprintf('E_0 = %.1e V/m', E0_list(k)));
end
xlabel('time [fs]');
ylabel('normalized smoothed envelope');
legend('Location', 'best');
mbfdtd1d_publication_style(gca);
title('Waveguide gain saturation envelopes');
ylim([0, 1.03]);
mbfdtd1d_export_figure(fig, fullfile(cfg.export.out_dir, 'waveguide_envelopes'), cfg.export.png_dpi);

%% Spatial snapshot
fig = figure('Color', 'w');
yyaxis left;
plot(results{3}.z * 1e6, results{3}.snapshot.Ex, 'LineWidth', 1.2);
ylabel('E_x [V/m]');
yyaxis right;
plot(results{3}.z * 1e6, results{3}.snapshot.rho3, '--', 'LineWidth', 1.2);
ylabel('ho_{3}');
xlabel('z [\mum]');
title('Waveguide spatial snapshot');
mbfdtd1d_publication_style(gca);
mbfdtd1d_export_figure(fig, fullfile(cfg.export.out_dir, 'waveguide_spatial_snapshot'), cfg.export.png_dpi);

%% Response summary
fig = figure('Color', 'w');
hold on;
for k = 1:numel(results)
    rho_end = results{k}.snapshot.rho3(cfg.material.is_gain);
    plot(results{k}.time * 1e12, envs{k}, ...
        'LineWidth', 1.2, 'DisplayName', sprintf('E_0 = %.1e', E0_list(k)));
    text(0.02*max(results{k}.time*1e12), 0.92 - 0.08*k, ...
        sprintf('\rho_3(end) mean = %.3f', mean(rho_end)), ...
        'Units', 'normalized');
end
xlabel('time [ps]');
ylabel('smoothed envelope [a.u.]');
title('Waveguide response summary');
legend('Location', 'best');
ymax = max(cellfun(@(x) max(x), envs));
ylim([0, 1.05 * ymax]);
mbfdtd1d_publication_style(gca);
mbfdtd1d_export_figure(fig, fullfile(cfg.export.out_dir, 'waveguide_population_relaxation'), cfg.export.png_dpi);

save(fullfile(cfg.export.out_dir, 'waveguide_validation.mat'), 'cfg', 'results', 'envs');
disp('Waveguide validation completed.');
