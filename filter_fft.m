function [freq, P1] = filter_fft(sig, fs, range)
    Y = fft(sig);
    L = size(sig, 2);
    P2 = abs(Y/L);
    P1 = P2(1:fix(L/2+1));
    P1(2:end-1) = 2*P1(2:end-1);
    freq = fs*(0:(L/2))/L;

    P1 = zeros(size(Y));
    P1(2:L/2) = 0.5*P1(2:end);
    P1(L/2:end) = 0.5*P1(2:end);  %  check boundaries
    P1 = ifft(P1);
end