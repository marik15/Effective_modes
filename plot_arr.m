%  Строит график суммы под кривой Фурье-спектра по нескольким областям от времени на одном графике

clearvars;
close all;
clc;

step = 500;  %  по сколько отсчетов шагаем

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
path_output = 'D:\MATLAB\Эффективные моды\Графики распределения энергии с числом мод\';

files = dir(append(path_aux, '*.mat'));
files = files(~ismember({files.name}, {'.', '..'}));

for files_id = 1:numel(files)
    [arr, fs, range, n_eff_arr] = get_arr(path_aux, files(files_id).name, step, false);
    t = (1:size(arr, 1))*step/fs*(1e+12);  %  время отсчетов, пс

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);  %#ok<LAXES>
    hold(ax, 'on');
    grid(ax, 'on');
    box(ax, 'on');

    labels = cell(0);
    p = [];
    for k = 1:size(range, 1)
        plt = plot(ax, t, arr(:, k), 'LineWidth', 0.001, 'LineStyle', '-');  %  , 'Color', colors{k}, 'MarkerFaceColor', colors{k}
        p = [p, plt];  %#ok<*AGROW>
        lbl = append(num2str(range(k, 1)), '-', num2str(range(k, 2)), ' см^{-1}');
        labels = [labels, lbl];
    end

    xlim(ax, [0, ceil(t(end))]);
    %[txts, l, ptc] = add_labels(ax, t, arr, n_eff_arr);
    title(ax, append(files(files_id).name(1:end-4), ' распределение энергии по областям'), 'Interpreter', 'None');
    xlabel(ax, 'Время, пс');
    ylabel(ax, 'Энергия, ккал/моль');
    lgd = legend(ax, p, labels, 'Location', 'best');
    box(ax, 'on');
    grid(ax, 'on');
    set(ax, 'FontSize', 24);
    %exportgraphics(fig, append(path_output, files(files_id).name(1:end-4), ' порог=', num2str(0.5), '.png'), 'Resolution', 300);
    close(fig);
end