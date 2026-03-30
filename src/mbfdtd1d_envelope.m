function env = mbfdtd1d_envelope(x)
%MBFDTD1D_ENVELOPE Analytic-signal envelope without Signal Processing Toolbox.

x = x(:);
N = numel(x);
X = fft(x);
H = zeros(N,1);

if mod(N,2) == 0
    H(1) = 1;
    H(N/2+1) = 1;
    H(2:N/2) = 2;
else
    H(1) = 1;
    H(2:(N+1)/2) = 2;
end

xa = ifft(X .* H);
env = abs(xa);
end
