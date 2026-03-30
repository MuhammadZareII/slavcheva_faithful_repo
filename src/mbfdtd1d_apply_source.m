function Ex = mbfdtd1d_apply_source(Ex, cfg, t, source_mask)
%MBFDTD1D_APPLY_SOURCE Inject source / cavity noise.

switch lower(cfg.source.mode)
    case 'cw'
        idx = cfg.source.position_index;
        omega0 = cfg.physics.omega0;
        n_ramp = max(1, cfg.source.ramp_cycles);
        T0 = 2*pi / omega0;
        t_ramp = n_ramp * T0;

        if t < t_ramp
            ramp = 0.5 * (1 - cos(pi * t / t_ramp));
        else
            ramp = 1.0;
        end

        Ex(idx) = Ex(idx) + cfg.source.amplitude * ramp * sin(omega0 * t);

    case 'noise'
        if cfg.source.noise_only_in_cavity
            Ex(source_mask) = Ex(source_mask) + cfg.source.noise_sigma .* randn(1, nnz(source_mask));
        else
            Ex = Ex + cfg.source.noise_sigma .* randn(size(Ex));
        end

    case 'none'
        % no-op

    otherwise
        error('Unknown source mode: %s', cfg.source.mode);
end
end
