function env_s = mbfdtd1d_smooth_envelope(t, x, lambda0, n_eff, cycles)
%MBFDTD1D_SMOOTH_ENVELOPE Smoothed analytic-signal envelope.
%
% cycles sets the moving-average span in optical cycles. This produces a
% visually meaningful build-up trace for cavity plots while preserving the
% slower gain / relaxation dynamics.

if nargin < 5 || isempty(cycles)
    cycles = 6;
end
if nargin < 4 || isempty(n_eff)
    n_eff = 1.0;
end

env = mbfdtd1d_envelope(x(:));

dt = mean(diff(t(:)));
T0 = lambda0 / (299792458 / n_eff);
span = max(5, round(cycles * T0 / dt));
span = min(span, numel(env));

env_s = movmean(env, span);
end
