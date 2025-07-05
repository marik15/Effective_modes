%  Строит график по решению системы уравнений

function fig = plot_sol(t, arr, t_de, sol, title_str)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);
    hold(ax, 'on');
    box(ax, 'on');
    grid(ax, 'on');

    labels = cell(0);
    p = [];

    for k = 1:size(arr, 2)
        plt = plot(ax, t, arr(:, k), 'LineWidth', 4, 'LineStyle', '-');
        p = [p, plt];  %#ok<*AGROW>
        lbl = append(num2str(range(k, 1)), '-', num2str(range(k, 2)), ' см^{-1}');
        labels = [labels, lbl];
    end

    p_R = plot(ax, t_de, sol(:, 1), 'Color', p(1).Color, 'LineWidth', 4);
    p_A = plot(ax, t_de, sol(:, 2), 'Color', p(2).Color, 'LineWidth', 4);
    p_B = plot(ax, t_de, sol(:, 3), 'Color', p(3).Color, 'LineWidth', 4);

    xlim(ax, [0, ceil(t(end))]);
    legend(ax, [p, p_A, p_B, p_R], {'Radial', 'Angular', 'Bending', 'Radial approximation', 'Angular approximation', 'Bending approximation'});
    title(ax, title_str, 'Interpreter', 'none');
    xlabel(ax, 'Время, пс');
    ylabel(ax, 'Энергия, ккал/моль');
    legend(ax, p, labels, 'Location', 'best');
    set(ax, 'FontSize', 24);
end