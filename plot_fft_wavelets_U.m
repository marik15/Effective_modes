% Строит векторы U и Фурье спектры каждого левого сингулярного базиса от матрицы кинетической энергии

function [fig, fig2] = plot_fft_wavelets_U(U, fs, xlimit, t1, s, k_arr, k_mean)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    n = length(k_arr);  %  число нарисованных графиков
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
        hold(ax_s, 'on');
        [freq, P1] = fourier_transform(U(:, mode_id)', fs);
        freq = freq/3E+10;  %  перевод в обратные см
        p_fft = plot(ax_s, freq, P1, 'LineWidth', 1);
        xlim(ax_s, xlimit*[-0.01, 1]);
        title(ax_s, append('\lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        xlabel(ax_s, 'Frequency, cm^{-1}');
        
        [cfs, frq] = cwt(U(:, mode_id), fs);
        cfs = abs(cfs);
        frq = frq/3E10;  %  перевод в обратные см
        z = movmean(cfs, k_mean, 2);
        z_eco = zeros(size(z, 1), fix((size(U, 1)-1)/k_mean) + 1);
        tmp = 1;
        while (tmp <= size(z_eco, 2))
            z_eco(:, tmp) = z(:, 1 + k_mean*(tmp-1));
            tmp = tmp + 1;
        end

        I = sum(abs(z_eco), 2);
        p_wv = plot(ax_s, frq, I/max(abs(I(end-numel(frq(frq <= xlimit)):end)))*max(abs(P1(1:numel(freq(freq <= xlimit))))));

        [~, m_fft] = max(P1(1:numel(freq(freq <= xlimit))));
        [~, m_wv] = max(I(end - numel(frq(frq <= xlimit)) + 1:end));
        legend([p_fft, p_wv], {num2str(round(freq(m_fft))), num2str(round(frq(end - numel(frq(frq <= xlimit)) + m_wv)))}, 'location', 'best');

        set([ax_U, ax_s], 'FontSize', 14);
    end
end