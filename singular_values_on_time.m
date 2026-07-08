%  Строит график N_eff от времени

clearvars;  %  удалить все переменные
close all;  %  закрыть все графики
clc;  %  очистить вывод

path_data = 'D:\MATLAB\Эффективные моды\data\';  %  папка с файлами, в конце символ \
files = {'w3_1a.irc';
         'w3_2a.irc';
         'w3_3a.irc'
         'w3_3a_1.irc';
         'w3_3a_2.irc';
         'w3_4a.irc'};  %  имена файлов

t_step = 5;  %  шаг, отсчеты
t1 = 1;  %  начало траектории
t2 = 'end';  % конец траектории: целое число, либо слово 'end', если нужно посчитать до конца файла, а число строк неизвестно

% --- ниже не нужно редактировать

k_kkal_mole = 627.5095;  %  коэффициент перевода а.е.м. * (бор/фс)^2 в ккал/моль: E = 0.5 * k * m * V^2;

output_path = [path_data, 'Сингулярные числа\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

for k = 1:1  %  numel(files)
    filename = [path_data, files{k}];
    [n, qVxyz_full, ~, fs] = load_n_qVxyz_xyz_fs(path_data, filename);  %  считываем данные из .irc

    if (strcmp(t2, 'end'))
        t2 = size(qVxyz_full, 1);
    end

    N = zeros(fix((t2-t1+1)/t_step), 1);

    for t = 0:fix((t2-t1+1)/t_step) - 1  %  цикл по временным участкам
        t1_cur = t1 + t * t_step;
        t2_cur = t1_cur + t_step - 1;

        qVxyz = qVxyz_full(t1_cur:t2_cur, :);
        E12 = energy_power(qVxyz, 0.5);
        s = svd(E12 - mean(E12), 0);  %  сингулярные числа в порядке невозрастания

        s = s.^2 / size(E12, 1) * k_kkal_mole;  %  энергия, ккал/моль
        N(t + 1) = count_N_eff(s);
    end

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);  %#ok<LAXES>
    hold(ax, 'on');
    grid(ax, 'on');
    box(ax, 'on');
    plot(ax, t_step * (0:fix((t2-t1+1)/t_step) - 1) * 1e+12 / fs, N, 'LineWidth', 2, 'Marker', 'square');  %  построение графика
    xlabel(ax, '$t$, ps', 'Interpreter', 'latex');
    ylabel(ax, '$N_{eff}$', 'Interpreter', 'latex');
    set(ax, 'FontSize', 40);
    %exportgraphics(fig, append(files{k}(1:end-4), '.png'), 'Resolution', 300);
    %close(fig);
end

fprintf('\t%s\n\t%s\n\t%s\n', string(datetime('now')), 'Файлы с сингулярными числами записаны по адресу:', output_path);