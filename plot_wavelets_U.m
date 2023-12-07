% Строит векторы U и вейвлет спектры каждого левого сингулярного базиса от матрицы кинетической энергии

function [fig, fig2] = plot_wavelets_U(U, fs, xlimit, t1, s, k_arr, k_mean)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    n = length(k_arr);  %  число нарисованных графиков
    [h, w] = compute_h_w(n);
    t_U = tiledlayout(fig, h, w);
    t_w = tiledlayout(fig2, h, w);
    for mode_id = k_arr
        %%{
        ax_U = nexttile(t_U);
        scatter(ax_U, (t1:t1+size(U, 1)-1)/fs, U(:, mode_id), 4, '.');  %  1:size(U, 1)
        xlim(ax_U, [t1, t1+size(U, 1)-1]/fs);  %  [1, size(U, 1)]
        title(ax_U, append('U_{', num2str(mode_id), '}: \lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        %xlabel(ax_U, 'Seconds');
        %%}

        %%{
        ax_wv = nexttile(t_w);
        [cfs, frq] = cwt(U(:, mode_id), fs);
        cfs = abs(cfs);
        frq = frq/3E10;  %  перевод в обратные см
        t_eco = (t1:k_mean:t1+size(U, 1)-1)/fs;
        z = movmean(exp(cfs), k_mean, 2);
        z_eco = zeros(size(z, 1), fix((size(U, 1)-1)/k_mean) + 1);
        tmp = 1;
        while (tmp <= size(z_eco, 2))
            z_eco(:, tmp) = z(:, 1 + k_mean*(tmp-1));
            tmp = tmp + 1;
        end
        surf(ax_wv, t_eco, frq, z_eco, 'EdgeColor', 'none', 'LineStyle', 'none', 'FaceLighting', 'phong');  %  shift+1:shift+size(U, 1)
        colormap(ax_wv, 'gray');
        view(ax_wv, 2);
        colorbar(ax_wv);
        xlim(ax_wv, [t1, t1+size(U, 1)-1]/fs);
        ylim(ax_wv, [frq(end), xlimit]);
        title(ax_wv, append('\lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        %xlabel(ax_wv, 'Seconds');
        ylabel(ax_wv, 'Frequency, cm^{-1}');
        %%}

        set([ax_U, ax_wv], 'FontSize', 14);
    end
end