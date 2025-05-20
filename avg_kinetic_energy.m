% Вычисляет среднюю кинетическую энергию, указанную в шапке .irc-файла

clearvars;
clc;
close all;

path_data = 'E:\MATLAB\Эффективные моды\data\';  %  папка с файлами, в конце символ \
path_aux = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\';

files = dir(append(path_aux, '*.mat'));

T_avg = 0.5e-12;  %  ширина усреднения
t1 = 1;  %  начиная с какого отсчёта по времени усреднять
t2 = 10000;  %  последний отсчёт по времени

% --- ниже не нужно редактировать

for file_id = 9  %  1:numel(files)
    filename = append(path_data, files(file_id).name(1:end-4), '.irc');
    [~, name, ~] = fileparts(filename);
    LOAD = load(append(files(file_id).folder, '\', files(file_id).name));
    n = LOAD.n;
    fs = LOAD.fs;

    file = fopen(filename);
    t = 0;  %  номер измерения
    energy = zeros(1, 1);  %  массив энергий

    while (~feof(file))
        t = t + 1;  %  чтение всего файла
        for i = 1:2  %  пропуск заголовков
            [~] = fgetl(file);
        end
        line = fgetl(file);
        line = line(11:end);  %  убираем значение TIME
        values = str2num(line);  %#ok<ST2NM>
        energy(t, 1) = values(1);  %  энергия из строчки
        for j = 1:n+2
            [~] = fgetl(file);
        end
    end
    fclose(file);

    w = round(T_avg*fs);
    N_T = fix((t2 - t1 + 1)/w);

    avg_energy = zeros(N_T, 1);

    for int_id = 1:N_T
        avg_energy(int_id) = mean(energy(t1 + w * (int_id - 1):t1 + w * int_id - 1));
    end

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);  %#ok<LAXES>
    grid(ax, 'on');
    box(ax, 'on');
    hold(ax, 'on');
    x = (t1:w:t1 + w * (N_T - 1))/fs;  %  пикосекунды
    plot(ax, x, avg_energy, 'b', 'Marker', 'o');  %  t1:w:t1 + w * N_T - 1
    m = mean(energy(t1:t2));
    plot(ax, x([1, end]), [m, m], 'r');
    xlim(ax, x([1, end]));
    ylim(ax, [min(avg_energy), max(avg_energy)]);
    title(ax, ['Средняя кинетическая энергия из файла ', files(file_id).name(1:end-4), ', среднее = ', num2str(mean(energy(t1:t2)))], 'Interpreter', 'None');
    xlabel(ax, 'Время, пс');
    ylabel(ax, 'Средняя кинетическая энергия');
    set(ax, 'FontSize', 32);
    close(fig);
end