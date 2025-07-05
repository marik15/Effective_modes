clearvars;
close all;
clc;

LOAD = load('D:\MATLAB\Эффективные моды\scripts\Results all 2025-06-23 16-43-32.mat');
path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
used_flags = false(4, numel(LOAD.filename), 1);
path_output = append('D:\MATLAB\Эффективные моды\Топ-4 лучших k\');
if (~isfolder(path_output))
    mkdir(path_output);  %  создание папки с результатами
end

for file_id = 1:numel(LOAD.filename)
    flag = false;
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    for top = 1:4
        if (~used_flags(top, file_id))
            [filenames, indexes] = get_similar_names(path_aux, LOAD.filename{file_id});
            %E_kin_rab = cell(numel(filenames), 1);
            x = zeros(numel(filenames), 1);
            y = zeros(numel(filenames), 6);
            for idx = 1:numel(filenames)
                %E_kin_rab{idx} = get_initial_data('D:\MATLAB\Эффективные моды\initial_data.xlsx', filenames{idx});
                x(idx) = idx - 1;  %sum(E_kin_rab{idx});  %  сумма в трех промежутках
                y(idx, :) = LOAD.k_best{indexes(idx)}(top, :);
            end
            ax = subplot(2, 2, top, axes(fig));  %#ok<LAXES>
            p = semilogy(ax, x, y(:, 1:6), 'LineWidth', 2, 'Marker', '*', 'MarkerSize', 40);
            box(ax, 'on');
            grid(ax, 'on');
            set(ax, 'FontSize', 20);
            xlabel(ax, append('X: ', filenames{1}, '_X'), 'Interpreter', 'none', 'FontSize', 20);  %  Полная кинетическая энергия, ккал/моль
            ylabel(ax, 'Значения коэффициентов k_{-3,...,+3}, пс^{-1}', 'FontSize', 20);
            title(ax, append('Топ-', num2str(top), ' коэффициенты k_{-3,...,+3} для ', filenames{1}, '_X'), 'Interpreter', 'none');
            legend(ax, p, {'k_1', 'k_{-1}', 'k_2', 'k_{-2}', 'k_3', 'k_{-3}'}, 'Location', 'best');
            used_flags(top, indexes) = true;
            flag = true;
        end
    end
    if flag
        saveas(fig, append(path_output, filenames{1}, '_X.png'));
    end
    close(fig);
end