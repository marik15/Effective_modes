%  Рисует графики сингулярных чисел от имени файла

clearvars;
close all;
clc;

path_data = 'C:\MATLAB\Эффективные моды\Вспомогательные файлы\';

origs = {'I', 'II', 'III', 'IV', 'V', 'VI'};  %  идентификаторы группы

if (~isfolder('C:\MATLAB\Эффективные моды\lambda\'))
    mkdir('C:\MATLAB\Эффективные моды\lambda\');
end

for k = 1:numel(origs)
    file_orig = origs{k};
    files = dir(append(path_data, '*\h2o_', file_orig, '_*.mat'));  %  файлы
    files_num = zeros(1, numel(files));
    I = zeros(numel(files), 9);  %  3 * число атомов

    for id = 1:numel(files)
        files_num(id) = str2double(files(id).name(length(file_orig) + 6:end-4));
        LOAD = load(append(files(id).folder, '\', files(id).name));
        qVxyz_full = LOAD.qVxyz_full;
        E12_full = sqrt_energy(qVxyz_full);
        T = E12_full;
        [U, S, V] = svd(T - mean(T), 0);
        I(id, :) = diag(S)';
    end
    
    fig1 = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
    ax1 = axes(fig1);
    lambda = 1;
    plot(ax1, files_num, I(:, lambda));
    xlim(ax1, files_num([1, end]));
    title(ax1, append('Расчет для группы h2o_', file_orig), 'Interpreter', 'None');
    xlabel(ax1, 'Имя файла');
    ylabel(ax1, '\lambda_{1}', 'Rotation', 0);
    set(ax1, 'FontSize', 14);
    saveas(fig1, append('C:\MATLAB\Эффективные моды\lambda\lambda_', num2str(lambda), ' h2o_', file_orig, '.png'));
    close(fig1);

    fig2 = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
    ax2 = axes(fig2);
    surf(ax2, files_num, 1:size(I, 2), I');
    xlim(ax2, files_num([1, end]));
    ylim(ax2, [1, size(I, 2)]);
    title(ax2, append('Расчет для группы h2o_', file_orig), 'Interpreter', 'None');
    xlabel(ax2, 'Имя файла');
    ylabel(ax2, 'Номер сингулярного числа i');
    zlabel(ax2, '\lambda_{i}', 'Rotation', 0);
    set(ax2, 'FontSize', 14);
    saveas(fig2, append('C:\MATLAB\Эффективные моды\lambda\lambda h2o_', file_orig, '.png'));
    close(fig2);
end