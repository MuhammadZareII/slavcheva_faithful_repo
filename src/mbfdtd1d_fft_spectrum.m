function spec = mbfdtd1d_fft_spectrum(t, x, window_name)
%MBFDTD1D_FFT_SPECTRUM One-sided FFT spectrum helper.
%
% Returns only strictly positive frequencies, removes the DC component,
% and performs a safe wavelength conversion so plotting scripts do not
% collapse to a spurious spike at lambda = inf.

t = t(:);
x = x(:);
assert(numel(t) == numel(x), 't and x must have the same length.');

if numel(t) < 8
    error('Signal too short for spectral analysis.');
end

dt = mean(diff(t));
fs = 1 / dt;
N = numel(x);

switch lower(window_name)
    case 'hann'
        w = 0.5 - 0.5*cos(2*pi*(0:N-1)'/(N-1));
    case 'none'
        w = ones(N,1);
    otherwise
        error('Unsupported window: %s', window_name);
end

xw = (x - mean(x)) .* w;
X = fft(xw);

% Strictly positive, one-sided spectrum.
k = (0:N-1)';
f = k * fs / N;
half = 2:floor(N/2);  % exclude DC bin explicitly

spec.frequency = f(half);
spec.power = abs(X(half)).^2 / sum(w.^2);
spec.lambda = 299792458 ./ spec.frequency;
spec.valid_lambda = isfinite(spec.lambda) & (spec.lambda > 0);
end
