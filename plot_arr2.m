%  Строит график суммы под кривой Фурье-спектра и долю вклада по нескольким областям от времени

clearvars;
close all;
clc;

step = 500;  %  по сколько отсчетов шагаем

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
path_output = 'D:\MATLAB\Эффективные моды\Графики распределения энергии и долей total\';

files = dir(append(path_aux, '*.mat'));
files = files(~ismember({files.name}, {'.', '..'}));

for files_id = 1:numel(files)
    [arr, fs, range, n_eff_arr, frac] = get_arr(path_aux, files(files_id).name, step, false);
    t = (1:size(arr, 1))*step/fs*(1e+12);  %  время отсчетов, пс

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    tile = tiledlayout(fig, 2, 1);  %  2 строки, 1 столбец
    ax1 = nexttile(tile, 1);  %  первая ось (верхняя)
    ax2 = nexttile(tile, 2);  %  вторая ось (нижняя)
    hold([ax1, ax2], 'on');
    grid([ax1, ax2], 'on');
    box([ax1, ax2], 'on');
    set([ax1, ax2], 'FontSize', 24);

    labels = cell(0);
    p = [];
    p2 = [];
    for k = 1:size(range, 1)
        plt = plot(ax1, t, arr(:, k), 'LineWidth', 2, 'LineStyle', '-', 'Marker', '*');  %  , 'Color', colors{k}, 'MarkerFaceColor', colors{k}
        p = [p, plt];  %#ok<*AGROW>
        lbl = append(num2str(range(k, 1)), '-', num2str(range(k, 2)), ' см^{-1}');
        labels = [labels, lbl];
        plt2 = plot(ax2, t, frac(1, :, k), 'LineWidth', 2, 'LineStyle', '-', 'Marker', '*');
        p2 = [p2, plt2];  %#ok<*AGROW>
    end

    xlim([ax1, ax2], [0, ceil(t(end))]);
    %[txts, l, ptc] = add_labels(ax, t, arr, n_eff_arr);
    title(ax1, append(files(files_id).name(1:end-4), ' распределение энергии по областям'), 'Interpreter', 'None');
    title(ax2, append(files(files_id).name(1:end-4), ' доля вклада в энергию каждой области (доля площади под графиком Фурье)'), 'Interpreter', 'None');
    ylabel(ax1, 'Энергия, ккал/моль');
    xlabel(ax2, 'Время, пс');
    ylabel(ax2, 'Доля, [0-1]');
    lgd = legend(ax1, p, labels, 'Location', 'bestoutside');
    %lgd2 = legend(ax2, p2, labels, 'Location', 'best');
    exportgraphics(fig, append(path_output, files(files_id).name(1:end-4), ' порог=', num2str(0.5), '.png'), 'Resolution', 300);
    close(fig);
end