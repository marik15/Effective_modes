% Строит векторы U и Фурье спектры каждого левого сингулярного базиса от матрицы кинетической энергии

function [fig, fig2] = plot_fft_U(U, fs, xlimit, t1, s, k_arr)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    n = length(k_arr);
    [h, w] = compute_h_w(n);
    t_U = tiledlayout(fig, h, w);
    t_s = tiledlayout(fig2, h, w);
    for mode_id = k_arr
        ax_U = nexttile(t_U);
        scatter(ax_U, (t1:t1+size(U, 1)-1)/fs, U(:, mode_id), 4, '.');
        xlim(ax_U, [t1, t1+size(U, 1)-1]/fs);
        title(ax_U, append('U_{', num2str(mode_id), '}: \lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        xlabel(ax_U, 'Seconds');

        ax_s = nexttile(t_s);
        [freq, P1] = fourier_transform(U(:, mode_id)', fs);
        freq = freq / 3e+10;  %  перевод в обратные см
        plot(ax_s, freq, P1, 'LineWidth', 1);
        xlim(ax_s, xlimit*[-0.01, 1]);
        title(ax_s, append('\lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        xlabel(ax_s, 'Frequency, cm^{-1}');

        set([ax_U, ax_s], 'FontSize', 14);
    end
end