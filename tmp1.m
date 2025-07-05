clearvars;
close all;
clc;

LOAD = load('D:\MATLAB\Эффективные моды\scripts\Results all 2025-06-23 16-43-32.mat');
path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';

step = 500;  %  по сколько отсчетов шагаем
const = 1e5;

d = dir(path_aux);
d([d.isdir]) = [];  %  remove . and .. and all subpaths

for file_id = 1:1%numel(d)
    [arr, fs, ~] = get_arr(path_aux, LOAD.filename{file_id}, step);
    t = (0:(size(arr, 1) - 1)) * step / (fs * (1e-12));  %  время, мс

    k = LOAD.k_best{file_id}(1, :);
    [t_de, sol] = ode15s(@(t, y) odefun_kin(t, y, k), linspace(t(1), t(end), const), arr(1, :));
    fig = plot_sol(t, arr, t_de, sol, d(file_id).name(1:end-4));
end