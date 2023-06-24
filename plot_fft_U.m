% Строит спектры каждого левого сингулярного базиса от матрицы кинетической энергии

function [fig, fig2] = plot_fft_U(U, fs, xlimit)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    n = size(U, 2);
    [h, w] = compute_h_w(n);
    t_U = tiledlayout(fig, h, w);
    t_s = tiledlayout(fig2, h, w);
    for mode_id = 1:size(U, 2)
        ax_U = nexttile(t_U);
        scatter(ax_U, 1:size(U, 1), U(:, mode_id), 4, '.');
        xlim(ax_U, [1, size(U, 1)]);
        title(ax_U, append('Мода ', num2str(mode_id)));
        xlabel(ax_U, 'Время');
        ylabel(ax_U, 'U');

        ax_s = nexttile(t_s);
        [freq, P1] = fourier_transform(U(:, mode_id)', fs);
        freq = freq/3E+10;  %  перевод в обратные см
        plot(ax_s, freq, P1, 'LineWidth', 1);
        xlim(ax_s, xlimit*[-0.01, 1]);
        title(ax_s, append('Мода ', num2str(mode_id)));
        xlabel(ax_s, 'Частота, см^{-1}');
        ylabel(ax_s, 'Модуль Фурье');

        set([ax_U, ax_s], 'FontSize', 14);
    end
end