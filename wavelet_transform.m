% Выводит график вейвлет-спектра сигнала с заданной частотой дискретизации

function fig = wavelet_transform(U, fs, i)
    [cfs, frq] = cwt(U(:, i), fs);
    frq = frq/3E10;
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
    surf(1:size(U, 1), frq, abs(cfs), 'EdgeColor', 'none', 'LineStyle', 'none', 'FaceLighting', 'phong');
    view(2);
    xlim([1, size(U, 1)]);
    ylim([frq(end), 5000]);
    title(['Вейвлет-спектр ', num2str(i), '-го сингулярного вектора'], 'FontSize', 14);
    xlabel('Время, номер отсчёта', 'FontSize', 14);
    ylabel('Частота, см^{-1}', 'FontSize', 14);
end