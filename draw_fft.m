function fig = draw_fft(U, K, fs)
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
    [freq, P1] = fourier_transform(U(1:80001, K)', fs);
    freq = freq/3E10;
    ax = axes(fig);
    plot(ax, freq, P1);
    xlim(ax, [0, 500]);
    xlabel(ax, 'Частота, см^{-1}', 'FontSize', 14);
    ylabel(ax, 'Модуль спектра', 'FontSize', 14);
    title(ax, ['Фурье-преобразование вектора №', num2str(K), ' в промежутке времени [1; 80001]'], 'FontSize', 14);
end