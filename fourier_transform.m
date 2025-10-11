%  Вычисляет модуль и частоты быстрого преобразования Фурье (fft)

function [frequencies, fourier_coeffs] = fourier_transform(sig, fs)
    N = numel(sig);  %  длина сигнала
    fourier_coeffs = abs(fft(sig) / N);
    if mod(N, 2) == 0  %  четное количество точек
        fourier_coeffs = fourier_coeffs(1:N/2 + 1);  %  для вещественных сигналов амплитуды симметричны, берем первую половину
        fourier_coeffs(2:end-1) = 2 * fourier_coeffs(2:end-1);  %  корректировка амплитуд (удваиваем все, кроме DC и Nyquist)
        frequencies = (0:N/2) * fs / N;
    else  %  нечетное количество точек
        fourier_coeffs = fourier_coeffs(1:(N + 1)/2);
        fourier_coeffs(2:end) = 2 * fourier_coeffs(2:end);  %  корректировка амплитуд (удваиваем все, кроме DC)
        frequencies = (0:(N - 1)/2) * fs / N;
    end
end