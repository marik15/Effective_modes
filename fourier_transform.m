% --- Вычисляет быстрое преобразование Фурье
function [freq, P1] = fourier_transform(sig, fs)
    Y = fft(sig);
    L = size(sig, 2);
    P2 = abs(Y/L);
    P1 = P2(1:fix(L/2+1));
    P1(2:end-1) = 2*P1(2:end-1);
    freq = fs*(0:(L/2))/L;
end