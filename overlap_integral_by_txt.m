% Достает интеграл перекрывания из текстового файла и строит картинку

clearvars;
close all;
clc;

path = 'C:\MATLAB\Эффективные моды\Матрицы сингулярные-нормальные\';
d = dir(append(path, '*.txt'));

fig = figure('Color', 'w', 'WindowState', 'maximized');

for k = [1]  %  [39, 41, 40, 42:46, 37, 38]
    filename = append(d(k).folder, '\', d(k).name);
    A = readmatrix(filename);
    A(:, end) = [];

    h = heatmap(fig, A);
    %h.ColorLimits = [0, 0.72];
    xlabel(h, 'Номер сингулярного вектора');
    ylabel(h, 'Номер нормального вектора');
    title(h, ['И' d(k).name(7:end-4)]);
    set(h, 'FontSize', 14);
    saveas(fig, append(d(k).name, '.png'));
end