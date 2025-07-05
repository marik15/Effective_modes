clearvars;
close all;
clc;

LOAD = load('D:\MATLAB\Эффективные моды\scripts\Results all 2025-06-23 16-43-32.mat');
path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
file_arr = {{'w3_1', 'w3_2', 'w3_3', 'w3_4'};
            {'w3_1a', 'w3_2a', 'w3_3a', 'w3_4a'};
            {'w3_1a_1', 'w3_2a_1', 'w3_3a_1', 'w3_4a_1'};
            {'w3_1a_2', 'w3_2a_2', 'w3_3a_2', 'w3_4a_2'};
            {'w4_1', 'w4_2', 'w4_3', 'w4_4'};
            {'w4_1a', 'w4_2a', 'w4_3a'};
            {'w4_1_1', 'w4_2_1', 'w4_3_1'};
            {'w4_1_2', 'w4_2_2', 'w4_3_2'};
            {'w4_1a_1', 'w4_2a_1', 'w4_3a_1'};
            {'w4_1a_2', 'w4_2a_2', 'w4_3a_2'};
            {'w5_1', 'w5_2', 'w5_3', 'w5_4'};
            {'w5_1a', 'w5_2a', 'w5_3a'};
            {'w3_1_1', 'w3_3_1'};
            {'w3_1_2', 'w3_3_2'};
            {'w4_1b', 'w4_2b'};
            {'w4_1b_1', 'w4_2b_1'};
            {'w4_1b_2', 'w4_2b_2'};
            {'w5_2_1', 'w5_3_1'};
            {'w5_2_2', 'w5_3_2'};
            {'w5_2a_1', 'w5_3a_1'};
            {'w5_2a_2', 'w5_3a_2'}};

names = LOAD.filename;
for idx = 1:numel(names)
    names{idx} = names{idx}(1:end-4);
end

for top = 1:1
    path_output = append('D:\MATLAB\Эффективные моды\Лучшие k топ-', num2str(top), ' по кластерам\');
    if (~isfolder(path_output))
        mkdir(path_output);  %  создание папки с результатами
    end
    for cluster_id = 1:numel(file_arr)
        filenames = file_arr{cluster_id};

        x = zeros(numel(filenames), 1);
        y = zeros(numel(filenames), 6);
        indexes = zeros(numel(filenames), 1);
        for k = 1:numel(filenames)
            indexes(k) = get_idxs(names, filenames{k});
        end
        for idx = 1:numel(filenames)
            x(idx) = idx;
            y(idx, :) = LOAD.k_best{indexes(idx)}(top, :);
        end
        fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
        ax = axes(fig);  %#ok<LAXES>
        p = semilogy(ax, x, y(:, 1:6), 'LineWidth', 2, 'Marker', '*', 'MarkerSize', 40);
        box(ax, 'on');
        grid(ax, 'on');
        set(ax, 'FontSize', 40);
        tit = '';
        for k = 1:numel(filenames)
            tit = append(tit, filenames{k}, ', ');
        end
        ax.XTick = 1:numel(filenames);
        xlabel(ax, append('Номер файла по порядку: ', tit(1:end-2)), 'Interpreter', 'none');  %  Полная кинетическая энергия, ккал/моль
        ylabel(ax, 'Значения коэффициентов k_{-3,...,+3}, пс^{-1}');
        title(ax, append('Зависимость коэффициентов k_{-3,...,+3} для ', tit(1:end-2)), 'Interpreter', 'none');
        legend(ax, p, {'k_1', 'k_{-1}', 'k_2', 'k_{-2}', 'k_3', 'k_{-3}'}, 'Location', 'east');
        saveas(fig, append(path_output, tit(1:end-2), '.png'));
        close(fig);
    end
end