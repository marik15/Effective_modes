% Возвращает очищенный прямоугольным ядром сигнал

function sig_filtered = filter_fft(sig, fs, range)
    L = length(sig);
    freq = fs*(0:(L/2))/L;
    freq = freq/3E+10;  %  частота в обратных сантиметрах
    mask = (freq >= range(1)) .* (freq <= range(end));  %  оставляем индексы, которые соответствуют частотному диапазону
    Y = fft(sig);
    Y = Y.*[mask, mask(end:-1:2)];
    sig_filtered = ifft(Y);
end