% Строит спектры каждого левого сингулярного базиса от матрицы кинетической энергии

function [fig, fig2] = plot_wavelets_U(U, fs, xlimit, t1, s, k_arr)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    fig2 = 0;
    %fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    n = length(k_arr);  %  число нарисованных графиков
    [h, w] = compute_h_w(n);
    t_U = tiledlayout(fig, h, w);
    %t_w = tiledlayout(fig2, h, w);
    for mode_id = k_arr
        %%{
        ax_U = nexttile(t_U);
        scatter(ax_U, (t1:t1+size(U, 1)-1)/fs, U(:, mode_id), 4, '.');  %  1:size(U, 1)
        xlim(ax_U, [t1, t1+size(U, 1)-1]/fs);  %  [1, size(U, 1)]
        title(ax_U, append('U_{', num2str(mode_id), '}: \lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        %xlabel(ax_U, 'Секунды');
        %%}

        %{
        ax_wv = nexttile(t_w);
        [cfs, frq] = cwt(U(:, mode_id), fs);
        cfs = abs(cfs);
        frq = frq/3E10;  %  перевод в обратные см
        surf(ax_wv, (t1:t1+size(U, 1)-1)/fs, frq, cfs, 'EdgeColor', 'none', 'LineStyle', 'none', 'FaceLighting', 'phong');  %  shift+1:shift+size(U, 1)
        colormap(ax_wv, 'jet');
        view(ax_wv, 2);
        colorbar(ax_wv);
        xlim(ax_wv, [t1, t1+size(U, 1)-1]/fs);  %  [shift+1, shift+size(U, 1)]
        ylim(ax_wv, [frq(end), xlimit]);
        title(ax_wv, append('\lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        %xlabel(ax_wv, 'Секунды');
        ylabel(ax_wv, 'Частота, см^{-1}');
        %}

        %set([ax_wv], 'FontSize', 14);
    end
end