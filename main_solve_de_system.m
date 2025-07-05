%  Решает систему дифференциальных уравнений кинетики

clearvars;
close all;
clc;

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';

step = 500;  %  по сколько отсчетов шагаем
const = 1e5;
N = 100;  %  число начальных приближений
top = 5;
lb = zeros(1, 6);
options = optimoptions('fmincon', 'OutputFcn', @myoutputfcn, 'Display', 'final', 'MaxIterations', 2e+2, 'MaxFunctionEvaluations', 1e+4);

d = dir(path_aux);
d([d.isdir]) = [];  %  remove . and .. and all subpaths

k_best = cell(numel(d), 1);
f_vals_best = cell(numel(d), 1);

for file_id = 1:numel(d)
    disp(string(datetime('now')));
    disp(append('Файл ', num2str(file_id), '/', num2str(numel(d)), ': ', d(file_id).name));
    tic;
    [arr, fs, ~] = get_arr(path_aux, d(file_id).name, step);
    t = (0:(size(arr, 1) - 1)) * step / (fs * (1e-12));  %  время, мс
    
    k_best{file_id} = zeros(top, 6);
    f_vals_best{file_id} = Inf(top, 1);
    
    for iter_id = 1:N
        disp(append('Итерация №', num2str(iter_id)));
        k0 = rand(1, 6);
        [k, f_val] = fmincon(@(k) energy_kinetics(k, arr, t, const), k0, [], [], [], [], lb, [], [], options);
        ind = 1;
        flag = true;
        while (flag && ((ind <= top) || (iter_id == 1)))
            if (f_val < f_vals_best{file_id}(ind, 1))
                k_best{file_id}(ind:end, :) = [k; k_best{file_id}(ind:end-1, :)];
                f_vals_best{file_id}(ind:end, 1) = [f_val; f_vals_best{file_id}(ind:end-1, 1)];
                flag = false;
            else
                ind = ind + 1;
            end
        end
    end
    toc;
    save(append('Result ', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), ' File ', num2str(file_id), '.mat'), 'k_best', 'f_vals_best');
end

%{
k = k_best{file_id}(1, :);
[t_de, sol] = ode15s(@(t, y) odefun_kin(t, y, k), linspace(t(1), t(end), const), arr(1, :));
fig = plot_sol(t, arr, t_de, sol, d(file_id).name(1:end-4));
%}

function stop = myoutputfcn(~, optimValues, ~)
    stop = false;
    if ((optimValues.iteration > 13) && (optimValues.fval > 5))  %  порог остановки
        disp('Неудачное начальное приближение');
        stop = true;
    end
end