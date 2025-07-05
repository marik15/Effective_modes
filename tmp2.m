clearvars;
close all;
clc;

LOAD = load('D:\MATLAB\Эффективные моды\scripts\Results all 2025-06-23 16-43-32.mat');
path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';

for top = 1:5
    path_output = append('D:\MATLAB\Эффективные моды\Лучшие k топ-', num2str(top), '\');
    if (~isfolder(path_output))
        mkdir(path_output);  %  создание папки с результатами
    end
    used_flags = false(numel(LOAD.filename), 1);
    for file_id = 1:numel(LOAD.filename)
        if (~used_flags(file_id))
            [filenames, indexes] = get_similar_names(path_aux, LOAD.filename{file_id});
            %E_kin_rab = cell(numel(filenames), 1);
            x = zeros(numel(filenames), 1);
            y = zeros(numel(filenames), 6);
            for idx = 1:numel(filenames)
                %E_kin_rab{idx} = get_initial_data('D:\MATLAB\Эффективные моды\initial_data.xlsx', filenames{idx});
                x(idx) = idx - 1;  %sum(E_kin_rab{idx});  %  сумма в трех промежутках
                y(idx, :) = LOAD.k_best{indexes(idx)}(top, :);
            end
            fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
            ax = axes(fig);  %#ok<LAXES>
            p = semilogy(ax, x, y(:, 1:6), 'LineWidth', 2, 'Marker', '*', 'MarkerSize', 40);
            box(ax, 'on');
            grid(ax, 'on');
            set(ax, 'FontSize', 40);
            xlabel(ax, append('X: ', filenames{1}, '_X'), 'Interpreter', 'none');  %  Полная кинетическая энергия, ккал/моль
            ylabel(ax, 'Значения коэффициентов k_{-3,...,+3}, пс^{-1}');
            title(ax, append('Зависимость коэффициентов k_{-3,...,+3} для ', filenames{1}, '_X'), 'Interpreter', 'none');
            legend(ax, p, {'k_1', 'k_{-1}', 'k_2', 'k_{-2}', 'k_3', 'k_{-3}'}, 'Location', 'best');
            saveas(fig, append(path_output, filenames{1}, '_X.png'));
            close(fig);
            used_flags(indexes) = true;
        end
    end
end