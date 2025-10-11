%  Строит график по решению системы уравнений

function fig = plot_sol(t, arr, t_de, sol, title_str, k_best, f_val)
    %range = [0, 320;
    %        320, 1200;
    %        1200, 2000];
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);
    hold(ax, 'on');
    box(ax, 'on');
    grid(ax, 'on');

    %labels = cell(0);
    p = [];
    ps = [];
    lw = [2, 4];

    for k = 1:size(arr, 2)
        p = [p, plot(ax, t, arr(:, k), 'LineWidth', lw(1), 'LineStyle', '-', 'Marker', '.')];  %#ok<*AGROW>
        %lbl = append(num2str(range(k, 1)), '-', num2str(range(k, 2)), ' см^{-1}');
        %labels = [labels, lbl];
        ps = [ps, plot(ax, t_de, sol(:, k), 'Color', p(k).Color, 'LineWidth', lw(2))];
    end

    xlim(ax, [0, ceil(t(end))]);
    title(ax, title_str, 'Interpreter', 'none');
    xlabel(ax, 'Время, пс');
    ylabel(ax, 'Энергия, ккал/моль');
    %legend(ax, p, labels, 'Location', 'best');
    set(ax, 'FontSize', 24);
    Str = {sprintf('k_1  = %s', replaceEwith10(k_best(1)));
           sprintf('k_{-1} = %s', replaceEwith10(k_best(2)));
           sprintf('k_2  = %s', replaceEwith10(k_best(3)));
           sprintf('k_{-2} = %s', replaceEwith10(k_best(4)));
           sprintf('k_3  = %s', replaceEwith10(k_best(5)));
           sprintf('k_{-3} = %s', replaceEwith10(k_best(6)));
           sprintf('RMSE: %.2f', f_val)};
    annotation(fig, 'textbox', [0.78, 0.825, 0.1, 0.1], 'String', Str, 'FontSize', 24);
    legend(ax, [p, ps], {'Radial', 'Angular', 'Bending', 'Radial approximation', 'Angular approximation', 'Bending approximation'}, 'Location', 'north');
end