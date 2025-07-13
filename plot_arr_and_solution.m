%  Строит график суммы под кривой Фурье-спектра по нескольким областям от времени на одном графике

clearvars;
close all;
clc;

step = 500;  %  по сколько отсчетов шагаем
const = 1e5;

LOAD = load('D:\MATLAB\Эффективные моды\scripts\Results all 2025-06-23 16-43-32.mat');
path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
path_output = append('D:\MATLAB\Эффективные моды\Графики решений для лучших k\');
if (~isfolder(path_output))
    mkdir(path_output);  %  создание папки с результатами
end

names = LOAD.filename;
for idx = 1:numel(names)
    names{idx} = names{idx}(1:end-4);
end

for file_id = 1:numel(names)
    [arr, fs, range] = get_arr(path_aux, append(names{file_id}, '.mat'), step);
    t = (1:size(arr, 1))*step/fs*(1e+12);  %  время отсчетов, пс

    k_best = LOAD.k_best{file_id}(1, :);
    [t_de, sol] = ode15s(@(t, y) odefun_kin(t, y, k_best), linspace(t(1), t(end), const), arr(1, :));
    fig = plot_sol(t, arr, t_de, sol, append(names{file_id}, ' распределение энергии по областям'), k_best);
    exportgraphics(fig, append(path_output, names{file_id}, ' порог=', num2str(0.5), '.png'), 'Resolution', 300);
    close(fig);
end