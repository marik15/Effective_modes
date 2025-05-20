%  Строит график по решению системы уравнений


function fig = plot_solution(t, arr, x, N)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);
    hold(ax, 'on');
    box(ax, 'on');
    grid(ax, 'on');

    for k = 1:size(arr, 2)
        p(k) = plot(ax, t, arr(:, k));  %#ok<AGROW>
    end

    t2 = linspace(t(1), t(end), 100*size(arr, 1));
    R_plt = zeros(size(t2));
    A_plt = zeros(size(t2));
    B_plt = zeros(size(t2));

    for t_id = 1:numel(t2)
        t_val = t2(t_id);
        R_plt(t_id) = 0.5 * sum((A(t_val, x, N, 1) .* x(1:N(1))             .* cos(x(1:N(1))             * t_val + x(sum(N)+(1:N(1))))           + A1(t_val, x, N, 1) .* sin(x(1:N(1))             * t_val + x(sum(N)+(1:N(1))))).^2);
        A_plt(t_id) = 0.5 * sum((A(t_val, x, N, 2) .* x(N(1)+(1:N(2)))      .* cos(x(N(1)+(1:N(2)))      * t_val + x(sum(N)+N(1)+(1:N(2))))      + A1(t_val, x, N, 2) .* sin(x(N(1)+(1:N(2)))      * t_val + x(sum(N)+N(1)+(1:N(2))))).^2);
        B_plt(t_id) = 0.5 * sum((A(t_val, x, N, 3) .* x(N(1)+N(2)+(1:N(3))) .* cos(x(N(1)+N(2)+(1:N(3))) * t_val + x(sum(N)+N(1)+N(2)+(1:N(3)))) + A1(t_val, x, N, 3) .* sin(x(N(1)+N(2)+(1:N(3))) * t_val + x(sum(N)+N(1)+N(2)+(1:N(3))))).^2);
    end
    p_R = plot(ax, t2, R_plt, 'Color', p(1).Color, 'LineWidth', 1.6);
    p_A = plot(ax, t2, A_plt, 'Color', p(2).Color, 'LineWidth', 1.6);
    p_B = plot(ax, t2, B_plt, 'Color', p(3).Color, 'LineWidth', 1.6);
    legend(ax, [p, p_A, p_B, p_R], {'Radial', 'Angular', 'Bending', 'Radial approximation', 'Angular approximation', 'Bending approximation'});
    xlabel(ax, 'Время, пс');
    ylabel(ax, 'Энергия, ккал/моль');
    set(ax, 'FontSize', 24);
end