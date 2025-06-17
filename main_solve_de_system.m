%  Решает систему дифференциальных уравнений кинетики

clearvars;
close all;
clc;

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
files_group = {'w5_2a.mat', 'w5_2a_1.mat', 'w5_2a_2.mat'};
file_id = 1;  %  какой файл
step = 500;  %  по сколько отсчетов шагаем
const = 1e6;

[arr, fs] = get_arr(path_aux, files_group, file_id, step);
t = (0:(size(arr, 1) - 1)) * step / (fs * (1e-12));  %  время, мс

k0 = rand(1, 6);

lb = zeros(1, 6);
options = optimoptions('fmincon', 'Display', 'iter', 'MaxIterations', 1e+3, 'MaxFunctionEvaluations', 3e+4);
[k, f_val] = fmincon(@(k) energy_kinetics(k, arr, t, const), k0, [], [], [], [], lb, [], [], options);

[t_de, sol] = ode15s(@(t, y) odefun_kin(t, y, k), linspace(t(1), t(end), const), arr(1, :));

fig = plot_sol(t, arr, t_de, sol, files_group{file_id}(1:end-4));

%  Строит график по решению системы уравнений

function fig = plot_sol(t, arr, t_de, sol, t_str)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);
    hold(ax, 'on');
    box(ax, 'on');
    grid(ax, 'on');

    for k = 1:size(arr, 2)
        p(k) = plot(ax, t, arr(:, k));  %#ok<AGROW>
    end

    p_R = plot(ax, t_de, sol(:, 1), 'Color', p(1).Color, 'LineWidth', 1.6);
    p_A = plot(ax, t_de, sol(:, 2), 'Color', p(2).Color, 'LineWidth', 1.6);
    p_B = plot(ax, t_de, sol(:, 3), 'Color', p(3).Color, 'LineWidth', 1.6);
    legend(ax, [p, p_A, p_B, p_R], {'Radial', 'Angular', 'Bending', 'Radial approximation', 'Angular approximation', 'Bending approximation'});
    title(ax, t_str, 'Interpreter', 'none');
    xlabel(ax, 'Время, пс');
    ylabel(ax, 'Энергия, ккал/моль');
    set(ax, 'FontSize', 24);
end