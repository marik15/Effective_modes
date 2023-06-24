% Строит график углов Эйлера от времени

clearvars;
close all;
clc;

path = 'C:\MATLAB\Эффективные моды\';  %  папка с irc-файлами, в конце символ \
files = {'w3_1.irc';
         'w3_2.irc';
         'w3_3.irc';
         'w4_1.irc';
         'w4_2.irc';
         'w4_3.irc';
         'w5_1.irc';
         'w5_2.irc';
         'w5_3.irc';
         'w5_4long.irc'};  %  имена файлов

L = 1000;  %  длина интервала, по которому усредняем повороты, отсчеты
dL = 1;  %  шаг, отсчеты

% --- ниже не нужно редактировать

fs = 2E+15;  %  частота дискретизации (сколько раз в секунду пишется: половина фемтосекунды)

for k = 5:5%numel(files)-1  %  1:numel(files)
    file = files{k};
    filename = append(path, file);
    [~, name, ~] = fileparts(filename);

    output_path = append(path, 'Вспомогательные файлы\');
    if (~isfolder(output_path))
        mkdir(output_path);  %  создание папки с вспомогательными файлами
    end
    
    mxyz_filename = append(output_path, name, '_xyz.mat');
    if (~isfile(mxyz_filename))
        [n, qVxyz, xyz] = get_n_qVxyz_xyz(filename);
        m = get_mass(qVxyz);
        save(mxyz_filename, 'm', 'xyz');
        fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файл для ускорения записан по адресу:', mxyz_filename);
    else
        load(mxyz_filename);
    end
    
    E12_filename = append(output_path, name, '_E12.mat');
    if (~isfile(E12_filename))
        E12 = sqrt_energy(qVxyz);  %  вычисляем квадратный корень из матрицы
        save(E12_filename, 'E12');  %  сохранение данных для ускорения
        fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файл для ускорения записан по адресу:', E12_filename);
    end

    start_arr = 1:dL:length(xyz) - L + 1;  %  начало первого интервала
    end_arr = start_arr + L - 1;  %  конец первого интервала
    angle_cur = zeros(numel(start_arr), 3);  %  первая строка - начальное приближение
    for t = 2:numel(start_arr)
        r0 = mean(xyz(start_arr(t-1):end_arr(t-1), :));  %  усреднение
        r1 = mean(xyz(start_arr(t):end_arr(t), :));
        alpha_init = angle_cur(t, :);
        d_angle = rotate_system(m, r1, r0);  %  разница углов для соседних моментов времени
        angle_cur(t, :) = [mod(angle_cur(t-1, 1) + d_angle(1), 2*pi), mod(angle_cur(t-1, 2) + d_angle(2), pi), mod(angle_cur(t-1, 3) + d_angle(3), 2*pi)];  %  текущее значение угла поворота
    end
    fig = figure('Color', 'w', 'WindowState', 'maximized');
    ax = axes(fig);  %#ok<LAXES>
    plot(ax, start_arr([1, end]), [0, 0], start_arr([1, end]), [2*pi, 2*pi], 'Color', 'k', 'LineStyle', '--');
    hold(ax, 'on');
    sc_alpha = scatter(ax, start_arr, angle_cur(:, 1));
    sc_beta = scatter(ax, start_arr, angle_cur(:, 2));
    sc_gamma = scatter(ax, start_arr, angle_cur(:, 3));
    ylim(ax, [-0.1, 2*pi + 0.1]);
    xlabel(ax, 'Номер отсчета');
    ylabel(ax, 'Угол поворота, радиан');
    title(ax, append('Зависимость углов Эйлера от времени, считая от начального положения, для ', name), 'Interpreter', 'None');
    legend(ax, [sc_alpha, sc_beta, sc_gamma], {'alpha', 'beta', 'gamma'});
    set(ax, 'FontSize', 14);
    saveas(fig, append(name, ' rotation.jpg'));
    save(append(name, '.mat'), 'start_arr', 'angle_cur');
    close(fig);
end