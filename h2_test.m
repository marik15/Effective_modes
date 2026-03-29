%  Рисует графики сингулярных чисел от имени файла

clearvars;
close all;
clc;

path_data = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\h2\';

files = dir(append(path_data, '*.mat'));  %  файлы

for file_id = 2  %  [1, 8]  %  1:numel(files)
    LOAD = load(append(files(file_id).folder, '\', files(file_id).name));
    qVxyz_full = LOAD.qVxyz_full;
    fs = LOAD.fs;
    E12_full = energy_power(qVxyz_full, 0.5);

    w = round((1000e-15)*fs);  %  ширина, отсчеты
    step = round((1e-15)*fs);  %  шаг, отсчеты

    n_steps = fix((size(E12_full, 1) - w + 1)/step);  %  число шагов по времени
    h2_energy = zeros(n_steps, 1);
    h2o_energy = zeros(n_steps, 1);

    for t = 1:n_steps
        T = E12_full((t-1)*step + (1:w), :);
        [U, S, V] = svd(T - mean(T), 0);  %  optional
        s = diag(S).^2;
        theta = s/sum(s);
        N_eff = exp(-sum(theta.*log(theta)));
        %k = 1;
        k = ceil(N_eff);
        U2 = complement_matrix(U, k);
        S2 = complement_matrix(S, k);
        V2 = complement_matrix(V, k);
        T2 = U2*S2*V2';
        h2_energy(t) = mean(sum(T2(:, end-5:end).^2, 2), 1)/((1e+4)/4.1868);  %  ккал
        h2o_energy(t) = mean(sum(T2(:, 1:end-6).^2, 2), 1)/((1e+4)/4.1868);
    end
end

time = (0:n_steps - 1)/fs*step;
fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
p_h2 = semilogy(ax, time, h2_energy);
hold(ax, 'on');
p_h2o = semilogy(ax, time, h2o_energy);
title(ax, append('Первые ', num2str(k), ' мод от ', files(file_id).name), 'Interpreter', 'none');
xlabel(ax, 'Время, пс');
ylabel(ax, 'Энергия, ккал');
legend(ax, [p_h2, p_h2o], {'h2', 'h2o'});
set(ax, 'FontSize', 24);
%saveas(fig, append(files(file_id).name, ' ', num2str(k), ' мод.png'));