%  Строит график суммы и решение от времени на одном графике

clearvars;
close all;
clc;

step = 500;  %  по сколько отсчетов шагаем
const = 3e4;

LOAD = load(append('D:\MATLAB\Эффективные моды\scripts\Result 3 order step ', num2str(step), ' all.mat'));
path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
path_output = append('D:\MATLAB\Эффективные моды\Графики решений уравнения 3 порядка шаг ', num2str(step), '\');
if (~isfolder(path_output))
    mkdir(path_output);  %  создание папки с результатами
end
top = 1;

names = LOAD.filename;

for file_id = 1:numel(names)
    if ~isempty(LOAD.k_best{file_id})
        [arr, fs, range, n_eff_arr] = get_arr(path_aux, append(names{file_id}, '.mat'), step, false);
        t = (1:size(arr, 1))*step/fs*(1e+12);  %  время отсчетов, пс
    
        k_best = LOAD.k_best{file_id}(top, :);
        [t_de, sol] = ode15s(@(t, y) odefun_kin(t, y, k_best), linspace(t(1), t(end), const), arr(1, :));
        fig = plot_sol(t, arr, t_de, sol, append(names{file_id}, ' распределение энергии по областям'), k_best, LOAD.f_vals_best{file_id}(top));
        exportgraphics(fig, append(path_output, names{file_id}, ' порог=', num2str(0.5), '.png'), 'Resolution', 300);
        close(fig);
    end
end