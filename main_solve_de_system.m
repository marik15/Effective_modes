%  Решает систему дифференциальных уравнений кинетики

clearvars;
close all;
clc;

needed_names = {'w3_2a_2'};
%  {'w3_2a'; 'w3_2a_1'; 'w3_2a_2'; 'w3_3a'; 'w3_3a_1'; 'w3_3a_2'; 'w3_4a'; 'w4_1b'; 'w4_1b_1'; 'w4_2_1'};

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';

step = 500;  %  по сколько отсчетов шагаем
temp = 'Result add 9_vars 6 order step ';
const = 3e4;
N = 100;  %  число начальных приближений
top = 5;
lb = zeros(1, 9);
%lb = zeros(1, 6);
options = optimoptions('fmincon', 'Display', 'none', 'MaxIterations', 5e+2, 'MaxFunctionEvaluations', 2e+4);  %  'OutputFcn', @myoutputfcn, 

d = dir(path_aux);
d([d.isdir]) = [];  %  remove . and .. and all subpaths
names = {d.name}';
for idx = 1:numel(names)
    names{idx} = names{idx}(1:end-4);
end

k_best = cell(numel(names), 1);
f_vals_best = cell(numel(names), 1);
y0_best = cell(numel(names), 1);
done = 0;

for file_id = 1:numel(names)  %  диапазон файлов
    if ismember(names{file_id}, needed_names)
        disp(string(datetime('now')));
        done = done + 1;
        fprintf(1, 'Файл %d/%d\t(%d/%d\t%.2f-%.2f%%):\t%s\n', file_id, numel(names), done, numel(needed_names), 100 * (done - 1)/numel(needed_names), 100 * done/numel(needed_names), names{file_id});
        tic;
        [arr, fs, ~, n_eff_arr] = get_arr(path_aux, append(names{file_id}, '.mat'), step, false);
        t = (0:(size(arr, 1) - 1)) * step / (fs * (1e-12));  %  время, мс

        k_best{file_id} = zeros(top, 6);
        f_vals_best{file_id} = Inf(top, 1);
        y0_best{file_id} = zeros(top, size(arr, 2));

        for iter_id = 1:N
            fprintf(1, 'Итерация № %d/%d:\t', iter_id, N);
            %k0 = rand(1, 6);  %  k0 = gamrnd(5.8, 20.7, 1, 6);
            x0 = [rand(1, 6), arr(1, :)];
            %[k, f_val, exitflag, output] = fmincon(@(k) energy_kinetics(k, arr, t, const), k0, [], [], [], [], lb, [], [], options);
            [x, f_val, exitflag, output] = fmincon(@(x) energy_kinetics(x, arr, t, const), x0, [], [], [], [], lb, [], [], options);
            f_val = f_val/sqrt(3*size(arr, 1));
            ind = 1;
            flag = true;
            while (flag && ((ind <= top) || (iter_id == 1)))
                if (f_val < f_vals_best{file_id}(ind, 1))
                    %k_best{file_id}(ind:end, :) = [k; k_best{file_id}(ind:end-1, :)];
                    k_best{file_id}(ind:end, :) = [x(1:6); k_best{file_id}(ind:end-1, :)];
                    f_vals_best{file_id}(ind:end, 1) = [f_val; f_vals_best{file_id}(ind:end-1, 1)];
                    y0_best{file_id}(ind:end, :) = [x(7:9); y0_best{file_id}(ind:end-1, :)];
                    flag = false;
                else
                    ind = ind + 1;
                end
            end
            fprintf(1, 'Точность:\t%.3f\tИтераций: %d\tВызовов функций: %d\texitflag: %d\n', f_val, output.iterations, output.funcCount, exitflag);
        end
        fprintf(1, 'Лучшая точность: %.3f\n', f_vals_best{file_id}(1, 1));
        toc;
        %save(append(temp, num2str(step), ' ', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), ' File ', names{file_id}, '.mat'), 'k_best', 'f_vals_best');
        save(append(temp, num2str(step), ' ', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), ' File ', names{file_id}, '.mat'), 'k_best', 'f_vals_best', 'y0_best');
    end
end