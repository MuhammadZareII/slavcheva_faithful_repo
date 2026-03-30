function out = mbfdtd1d_main(cfg)
%MBFDTD1D_MAIN Core 1-D paper-faithful Maxwell-Bloch / FDTD solver.
%
% Notes
% -----
% - Yee-like staggered Ex/Hy update
% - Two-level medium in real Bloch-vector form
% - Predictor-corrector iterations for field / medium coupling
% - Optional Mur absorbing boundaries
% - CW or Langevin-like white-noise source support
%
% This implementation prioritizes readability, auditability, and a clean
% repository architecture. It is intended as a professional reproduction
% framework, not as a black-box historical artifact.

rng(cfg.runtime.rng_seed, 'twister');

c0   = cfg.constants.c0;
eps0 = cfg.constants.eps0;
mu0  = cfg.constants.mu0;
hbar = cfg.constants.hbar;

z  = cfg.grid.z(:).';
dz = cfg.grid.dz;
Nz = cfg.grid.Nz;

n   = cfg.material.n(:).';
eps = eps0 * (cfg.material.eps_r(:).');
mu  = mu0 * ones(1, Nz);

omega0 = cfg.physics.omega0;
gamma  = cfg.physics.gamma;
Na     = cfg.physics.Na;
T1     = cfg.physics.T1;
T2     = cfg.physics.T2;
rho30  = cfg.material.rho30(:).';

dt = cfg.runtime.cfl_safety * dz / (c0 * max(n));
Nt = floor(cfg.runtime.t_end / dt) + 1;
time = (0:Nt-1) * dt;

probe_idx = cfg.observation.probe_index;
if isempty(probe_idx)
    probe_idx = round(0.9 * Nz);
end

snapshot_idx = [];
if ~isempty(cfg.runtime.snapshot_time)
    [~, snapshot_idx] = min(abs(time - cfg.runtime.snapshot_time));
end

source_mask = cfg.material.is_cavity(:).';

% State variables
Ex = zeros(1, Nz);
Hy = zeros(1, Nz-1);

rho1 = zeros(1, Nz);
rho2 = zeros(1, Nz);
rho3 = rho30;

probe_Ex = zeros(1, Nt);
probe_Hy = zeros(1, Nt);

store_every = max(1, cfg.runtime.store_every);
stored_t = [];
stored_probe = [];

% Mur ABC memory
Ex_left_old  = 0;
Ex_right_old = 0;
mur_coeff = (c0*dt/dz - 1) / (c0*dt/dz + 1);

C = gamma / hbar;

for it = 1:Nt
    tnow = time(it);

    % --- H update (staggered) ---
    Hy = Hy - (dt ./ (mu(1:end-1) * dz)) .* (Ex(2:end) - Ex(1:end-1));

    % --- Predictor-corrector on E and Bloch states ---
    Ex_new   = Ex;
    rho1_new = rho1;
    rho2_new = rho2;
    rho3_new = rho3;

    for pc = 1:cfg.solver.n_predictor_corrector
        Ex_avg = 0.5 * (Ex + Ex_new);

        drho1 = -rho1_new ./ T2 + omega0 .* rho2_new;
        drho2 = -rho2_new ./ T2 - omega0 .* rho1_new - 2*C .* Ex_avg .* rho3_new;
        drho3 = -(rho3_new - rho30) ./ T1 + 2*C .* Ex_avg .* rho2_new;

        rho1_trial = rho1 + dt .* drho1;
        rho2_trial = rho2 + dt .* drho2;
        rho3_trial = rho3 + dt .* drho3;

        if cfg.solver.clip_rho3
            clipv = cfg.solver.rho3_clip_value;
            rho3_trial = max(-clipv, min(+clipv, rho3_trial));
        end

        pol_term = -(Na*gamma ./ (eps*T2)) .* rho1_trial + (Na*gamma*omega0 ./ eps) .* rho2_trial;

        dHy_dz = zeros(1, Nz);
        dHy_dz(2:end-1) = (Hy(2:end) - Hy(1:end-1)) ./ dz;

        Ex_new = Ex - dt .* (dHy_dz ./ eps + pol_term);

        % source / spontaneous-emission-like cavity noise
        Ex_new = mbfdtd1d_apply_source(Ex_new, cfg, tnow, source_mask);

        rho1_new = rho1_trial;
        rho2_new = rho2_trial;
        rho3_new = rho3_trial;
    end

    % --- Boundary conditions ---
    if cfg.solver.use_mur_abc
        Ex_new(1)   = Ex(2)     + mur_coeff * (Ex_new(2)     - Ex(1));
        Ex_new(end) = Ex(end-1) + mur_coeff * (Ex_new(end-1) - Ex(end));
    else
        Ex_new(1) = 0;
        Ex_new(end) = 0;
    end

    % --- Commit state ---
    Ex = Ex_new;
    rho1 = rho1_new;
    rho2 = rho2_new;
    rho3 = rho3_new;

    probe_Ex(it) = Ex(probe_idx);
    probe_Hy(it) = Hy(max(1, min(numel(Hy), probe_idx-1)));

    if mod(it-1, store_every) == 0
        stored_t(end+1) = tnow; %#ok<AGROW>
        stored_probe(end+1) = Ex(probe_idx); %#ok<AGROW>
    end

    if ~isempty(snapshot_idx) && it == snapshot_idx
        snapshot.Ex = Ex;
        snapshot.Hy = Hy;
        snapshot.rho1 = rho1;
        snapshot.rho2 = rho2;
        snapshot.rho3 = rho3;
        snapshot.time = tnow;
    end
end

if isempty(snapshot_idx)
    snapshot.Ex = Ex;
    snapshot.Hy = Hy;
    snapshot.rho1 = rho1;
    snapshot.rho2 = rho2;
    snapshot.rho3 = rho3;
    snapshot.time = time(end);
end

out.cfg = cfg;
out.time = time;
out.dt = dt;
out.probe_Ex = probe_Ex;
out.probe_Hy = probe_Hy;
out.decimated.time = stored_t;
out.decimated.probe_Ex = stored_probe;
out.snapshot = snapshot;
out.z = z;
out.material = cfg.material;
end
