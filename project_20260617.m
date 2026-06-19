%  Решает систему дифференциальных уравнений кинетики

clearvars;
close all;
clc;

needed_names = {'w3_2a'; 'w3_2a_1'; 'w3_2a_2'; 'w3_3a'; 'w3_3a_1'; 'w3_3a_2'; 'w3_4a'; 'w4_1b'; 'w4_1b_1'; 'w4_2_1'};

path_data = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';

step = 500;  %  по сколько отсчетов шагаем
temp = 'Result add 9_vars 6 order step ';
const = 3e4;  %  число точек при аппроксимации решения
N = 100;  %  число начальных приближений
top = 5;
lb = zeros(1, 9);
%lb = zeros(1, 6);
options = optimoptions('fmincon', 'Display', 'none', 'MaxIterations', 5e+2, 'MaxFunctionEvaluations', 2e+4);  %  'OutputFcn', @myoutputfcn, 

d = dir(path_data);
d([d.isdir]) = [];  %  remove . and .. and all subpaths
names = {d.name}';
for idx = 1:numel(names)
    names{idx} = names{idx}(1:end-4);
end

k_best = cell(numel(names), 1);
f_vals_best = cell(numel(names), 1);
y0_best = cell(numel(names), 1);
done = 0;

for file_id = 1:numel(names)  %  диапазон файлов
    if ismember(names{file_id}, needed_names)
        disp(string(datetime('now')));
        done = done + 1;
        fprintf(1, 'Файл %d/%d\t(%d/%d\t%.2f-%.2f%%):\t%s\n', file_id, numel(names), done, numel(needed_names), 100 * (done - 1)/numel(needed_names), 100 * done/numel(needed_names), names{file_id});
        tic;
        [arr, fs, ~, n_eff_arr, ~] = get_arr(path_data, append(names{file_id}, '.mat'), step, false);
        t = (0:(size(arr, 1) - 1)) * step / (fs * (1e-12));  %  время, мс

        k_best{file_id} = zeros(top, 6);
        f_vals_best{file_id} = Inf(top, 1);
        y0_best{file_id} = zeros(top, size(arr, 2));

        for iter_id = 1:N
            fprintf(1, 'Итерация № %d/%d:\t', iter_id, N);
            %k0 = rand(1, 6);  %  k0 = gamrnd(5.8, 20.7, 1, 6);
            x0 = [rand(1, 6), arr(1, :)];
            %[k, f_val, exitflag, output] = fmincon(@(k) energy_kinetics(k, arr, t, const), k0, [], [], [], [], lb, [], [], options);
            [x, f_val, exitflag, output] = fmincon(@(x) energy_kinetics(x, arr, t, const), x0, [], [], [], [], lb, [], [], options);
            f_val = f_val/sqrt(3*size(arr, 1));
            ind = 1;
            flag = true;
            while (flag && ((ind <= top) || (iter_id == 1)))
                if (f_val < f_vals_best{file_id}(ind, 1))
                    %k_best{file_id}(ind:end, :) = [k; k_best{file_id}(ind:end-1, :)];
                    k_best{file_id}(ind:end, :) = [x(1:6); k_best{file_id}(ind:end-1, :)];
                    f_vals_best{file_id}(ind:end, 1) = [f_val; f_vals_best{file_id}(ind:end-1, 1)];
                    y0_best{file_id}(ind:end, :) = [x(7:9); y0_best{file_id}(ind:end-1, :)];
                    flag = false;
                else
                    ind = ind + 1;
                end
            end
            fprintf(1, 'Точность:\t%.3f\tИтераций: %d\tВызовов функций: %d\texitflag: %d\n', f_val, output.iterations, output.funcCount, exitflag);
        end
        fprintf(1, 'Лучшая точность: %.3f\n', f_vals_best{file_id}(1, 1));
        toc;
        %save(append(temp, num2str(step), ' ', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), ' File ', names{file_id}, '.mat'), 'k_best', 'f_vals_best');
        save(append(temp, num2str(step), ' ', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), ' File ', names{file_id}, '.mat'), 'k_best', 'f_vals_best', 'y0_best');
    end
end


% Проверяет, что время не вышло за границы диапазона по размеру файла

function [t1, t2, t_step] = check_t1_t2(t1, t2, t_step, T, filename)
    if isa(t2, 'char')
        t2 = T;
    end
    if (t2 > T)
        warning('%s\n%s\n%s\n%s\n\n', 'Внимание!', ['t2 введено больше (', num2str(t2), '), чем записано (', num2str(T), ') в файле:'], filename, ['t2 присвоено значение ', num2str(T)]);
        t2 = T;
    end
    if (t1 >= t2)
        warning('%s\n%s\n%s\n\n', 'Внимание!', ['t1 (', num2str(t1), ') введено больше либо равно, чем t2 (', num2str(t2), ')'], ['t1 присвоено значение ', num2str(1)]);
        t1 = 1;
    end
    if (t_step == 0)
        fprintf('%s\n%s\n\n', 'Обратите внимание!', ['Считаем траекторию (', num2str(t1), '-', num2str(t2), ')']);
        t_step = t2-t1+1;
    end
    if (t_step > t2-t1+1)
        warning('%s\n%s\n%s\n%s\n\n', 'Внимание!', ['t_step введен больше (', num2str(t_step), '), чем t2-t1+1 (', num2str(t2-t1+1), ') t_step присвоено значение ', num2str(t2-t1+1)]);
        t_step = t2-t1+1;
    end
end


% Вычисляет число молекул в системе по файлу .irc

function n = count_n(filename)
    file_tmp = fopen(filename);
    for i = 1:4  %  пропуск заголовков
        [~] = fgetl(file_tmp);
    end
    n = -1;
    flag = false;
    while (~flag)
        n = n + 1;
        line = fgetl(file_tmp);  %  считывание следующей строки
        vals = str2num(line);  %#ok<ST2NM>  %  преобразование строки в числа
        flag = isempty(vals);
    end
    fclose(file_tmp);
end


%  Вычисляет матрицу энергии в степени power

function E12 = energy_power(qVxyz, power)
    T = size(qVxyz, 1);  %  число отсчетов по времени
    n = size(qVxyz, 2)/4;  %  число частиц
    E12 = zeros(T, 3*n);
    for i = 1:T
        for j = 1:n
            m = mass_by_charge(qVxyz(i, 4*j-3));  %  масса
            if (power == 1)
                E12(i, 3*j-2) = 0.5*m*(qVxyz(i, 4*j-2)^2);  %  x
                E12(i, 3*j-1) = 0.5*m*(qVxyz(i, 4*j-1)^2);  %  y
                E12(i, 3*j) = 0.5*m*(qVxyz(i, 4*j)^2);  %  z
            elseif (power == 0.5)
                E12(i, 3*j-2) = sqrt(0.5*m)*qVxyz(i, 4*j-2);  %  x
                E12(i, 3*j-1) = sqrt(0.5*m)*qVxyz(i, 4*j-1);  %  y
                E12(i, 3*j) = sqrt(0.5*m)*qVxyz(i, 4*j);  %  z
            end
        end
    end
end


%  Вычисляет модуль и частоты быстрого преобразования Фурье (fft)

function [frequencies, fourier_coeffs] = fourier_transform(sig, fs)
    N = numel(sig);  %  длина сигнала
    fourier_coeffs = abs(fft(sig) / N);
    if mod(N, 2) == 0  %  четное количество точек
        fourier_coeffs = fourier_coeffs(1:N/2 + 1);  %  для вещественных сигналов амплитуды симметричны, берем первую половину
        fourier_coeffs(2:end-1) = 2 * fourier_coeffs(2:end-1);  %  корректировка амплитуд (удваиваем все, кроме DC и Nyquist)
        frequencies = (0:N/2) * fs / N;
    else  %  нечетное количество точек
        fourier_coeffs = fourier_coeffs(1:(N + 1)/2);
        fourier_coeffs(2:end) = 2 * fourier_coeffs(2:end);  %  корректировка амплитуд (удваиваем все, кроме DC)
        frequencies = (0:(N - 1)/2) * fs / N;
    end
end


%  Вычисляет массив сумм под кривой Фурье-спектра по нескольким областям от времени на одном графике

function [arr, fs, range, n_eff_arr, frac] = get_arr(path_aux, filename, step, is_min)
    threshold = 0.5;  %  доля энергии
    dx = 5;  %  шаг интегрирования по частоте
    T_width = 0.5e-12;  %  ширина скользящего окна, секунды

    range_3 = [0, 225
               225, 330;
               350, 610;
               610, 800;
               800, 1100;
               1200, 2000];  %  тример

    %%{
    range_3 = [5, 320;  %  Radial
               320, 1200;  %  Angular
               1200, 2000];  %  Bending
    %%}

    range_4 = range_3;  %#ok<*NASGU>  %  тетрамер
    range_5 = range_3;  %  пентамер

    range_6 = [0, 225;
               225, 330;
               350, 610;
               610, 850;
               850, 1100;
               1200, 2000];  %  гексамер

    range_7 = [0, 225;
               225, 330;
               350, 610;
               610, 830;
               830, 1100;
               1200, 2000];  %  гептамер

    range_8 = [0, 285;
               285, 330;
               350, 610;
               610, 900;
               900, 1100;
               1200, 2000];  %  гептамер

    if is_min
        [filenames, ~] = get_similar_names(path_aux, filename);
        min_n = Inf;
        for k = 1:numel(filenames)
            LOAD(k) = load(append(path_aux, filenames{k}));  %#ok<AGROW>
            if (size(LOAD(k).qVxyz_full, 1) <= min_n)
                min_n = size(LOAD(k).qVxyz_full, 1);
            end
        end
    end

    [startIndex, endIndex] = regexp(filename, '[a-z]+\d+');
    digit = filename(regexp(filename(startIndex:endIndex), '\d+'):endIndex);
    try
        range = eval(append('range_', num2str(digit)));  %  присваиваем интервал нужных частот
    catch
        error(append('Error: ', filename, ' is not suitable cluster. Update the frequency ranges.'));
    end
    for k = 1:size(range, 1)
        freqs_int{k} = range(k, 1):dx:range(k, 2);  %#ok<AGROW>
    end
    LOAD = load(append(path_aux, filename));
    if ~is_min
        min_n = size(LOAD.qVxyz_full, 1);
    end
    n = LOAD.n;
    fs = LOAD.fs;
    qVxyz_full = LOAD.qVxyz_full;

    N_width = T_width * fs;  %  ширина скользящего окна, отсчеты
    N_steps = fix(1 + (min_n - N_width)/step);
    arr = zeros(N_steps, size(range, 1));  %  массив с энергией в данный момент
    n_eff_arr = zeros(N_steps, 1);
    frac = zeros(n, N_steps, size(range, 1));  %  массив с долей кинетической энергии в каждом диапазоне в данный момент
    for time_id = 1:N_steps
        t = fix((1:N_width) + (time_id - 1) * step);
        E12_full = energy_power(qVxyz_full(t, :), 0.5);
        T = E12_full;
        [U, S, ~] = svd(T, 0);
        s = diag(S).^2 * sqrt((1e+4) / size(U, 1) / 4.1868);  %  энергия, ккал/моль
        n_eff = find(cumsum(s)/sum(s) >= threshold - (1e-10), 1);
        n_eff_arr(time_id) = n_eff;
        for mode_id = 1:n_eff
        %for mode_id = (n_eff+1):size(U, 2)
            [freq, fourier_coeffs] = fourier_transform(U(:, mode_id)', fs);
            freq = freq / 3e+10;
            idx = zeros(size(range, 1), size(freq, 2), 'logical');
            integral = zeros(1, size(range, 1));
            for row = 1:size(range, 1)
                idx(row, :) = ((range(row, 1) <= freq) & (freq < range(row, 2)));
                interpolant = interp1(freq, idx(row, :).*fourier_coeffs, freqs_int{row});
                integral(row) = trapz([freqs_int{row}(1) - dx, freqs_int{row}, freqs_int{row}(end) + dx], [0, interpolant, 0], 2);
            end
            integral_total = trapz(freq, fourier_coeffs, 2);
            arr(time_id, :) = arr(time_id, :) + s(mode_id) * integral / integral_total;  %  нормировка
            frac(mode_id, time_id, :) = integral/integral_total;
        end
    end
end


%  Вычисляет массив сумм под кривой Фурье-спектра по нескольким областям от времени на одном графике
%  arr = {r, a, b}

function [arr, fs, range, n_eff_arr, frac, freq, fourier_coeffs_arr, freqs_int] = get_arr_fourier(path_aux, filename, step, is_min)
    threshold = 0.5;  %  доля энергии
    dx = 5;  %  шаг интегрирования по частоте
    T_width = 0.5e-12;  %  ширина скользящего окна, секунды
    upper_limit = 5000;  %  верхний предел интегрирования, см^{-1}

    %{
    range_3 = [0, 225;
               225, 330;
               350, 610;
               610, 800;
               800, 1100;
               1200, 2000];  %  тример
    %}

    %%{
    range_3 = [5, 320;  %  Radial
               320, 1200;  %  Angular
               1200, 2000];  %  Bending
    %%}

    range_4 = range_3;  %#ok<*NASGU>  %  тетрамер
    range_5 = range_3;  %  пентамер

    range_6 = [0, 225;
               225, 330;
               350, 610;
               610, 850;
               850, 1100;
               1200, 2000];  %  гексамер

    range_7 = [0, 225;
               225, 330;
               350, 610;
               610, 830;
               830, 1100;
               1200, 2000];  %  гептамер

    range_8 = [0, 285;
               285, 330;
               350, 610;
               610, 900;
               900, 1100;
               1200, 2000];  %  октамер

    if is_min
        [filenames, ~] = get_similar_names(path_aux, filename);
        min_n = Inf;
        for k = 1:numel(filenames)
            LOAD(k) = load(append(path_aux, filenames{k}));  %#ok<AGROW>
            if (size(LOAD(k).qVxyz_full, 1) <= min_n)
                min_n = size(LOAD(k).qVxyz_full, 1);
            end
        end
    end

    [startIndex, endIndex] = regexp(filename, '[a-z]+\d+');
    digit = filename(regexp(filename(startIndex:endIndex), '\d+'):endIndex);
    try
        range = eval(append('range_', num2str(digit)));  %  присваиваем интервал нужных частот
    catch
        error(append('Error: ', filename, ' conteins not suitable cluster. Update the frequency ranges.'));
    end
    for k = 1:size(range, 1)
        freqs_int{k} = range(k, 1):dx:range(k, 2);  %#ok<AGROW>
    end
    LOAD = load(append(path_aux, filename));
    if ~is_min
        min_n = size(LOAD.qVxyz_full, 1);
    end
    n = LOAD.n;
    fs = LOAD.fs;
    qVxyz_full = LOAD.qVxyz_full;

    N_width = T_width * fs;  %  ширина скользящего окна, отсчеты
    N_steps = fix(1 + (min_n - N_width)/step);
    arr = zeros(N_steps, size(range, 1));  %  массив с энергией в данный момент
    n_eff_arr = zeros(N_steps, 1);
    frac = zeros(n, N_steps, size(range, 1));  %  массив с долей кинетической энергии в каждом диапазоне в данный момент
    fourier_coeffs_arr = zeros(n, N_steps, ceil((N_width + 1)/2));
    for time_id = 1:N_steps
        t = fix((1:N_width) + (time_id - 1) * step);
        E12_full = energy_power(qVxyz_full(t, :), 0.5);
        T = E12_full;
        [U, S, ~] = svd(T - mean(T), 0);
        s = diag(S).^2 * sqrt((1e+4) / size(U, 1) / 4.1868);  %  энергия, ккал/моль
        n_eff = find(cumsum(s)/sum(s) >= threshold - (1e-10), 1);
        n_eff_arr(time_id) = n_eff;
        for mode_id = 1:size(U, 2)
        %for mode_id = 1:n_eff
        %for mode_id = (n_eff+1):size(U, 2)
            [freq, fourier_coeffs] = fourier_transform(U(:, mode_id)', fs);
            freq = freq / 3e+10;
            fourier_coeffs_arr(mode_id, time_id, :) = fourier_coeffs;
            idx = zeros(size(range, 1), size(freq, 2), 'logical');
            integral = zeros(1, size(range, 1));
            for row = 1:size(range, 1)
                idx(row, :) = ((range(row, 1) <= freq) & (freq < range(row, 2)));
                interpolant = interp1(freq, idx(row, :).*fourier_coeffs, freqs_int{row});
                integral(row) = trapz([freqs_int{row}(1) - dx, freqs_int{row}, freqs_int{row}(end) + dx], [0, interpolant, 0], 2);
            end
            integral_total = trapz(freq(freq <= upper_limit), fourier_coeffs(freq <= upper_limit), 2);
            arr(time_id, :) = arr(time_id, :) + s(mode_id) * integral / integral_total;  %  добавление весов
            frac(mode_id, time_id, :) = integral/integral_total;
        end
    end
end


% Определяет частоту максимальной амплитуды в спектре

function main_freq = get_main_freq(freq, P1)
    [~, max_index] = max(P1);
    main_freq = freq(max_index);
end


% Возвращает по файлу n, матрицу вида [q1, Vx1, Vy1, Vz1, q2, Vx2, Vy2, Vz2,...] и [x1, y1, z1, x2, y2, z2,...] от t1 до t2 и fs

function [n, qVxyz, xyz, fs] = get_matrices(filename, t1, t2)
    n = count_n(filename);  %  число частиц, файл типа .irc
    file = fopen(filename);
    for i = 1:2
        [~] = fgetl(file);
    end
    tmp = str2num(fgetl(file));  %#ok<*ST2NM>
    time(1) = tmp(1);
    for i = 1:(n + 4)
        [~] = fgetl(file);
    end
    tmp = str2num(fgetl(file));
    time(2) = tmp(1);
    fs = (1e+15)/diff(time);
    fclose(file);
    file = fopen(filename);
    t = 0;  %  номер измерения
    K = 1000000;  %  число строк с запасом
    qVxyz = zeros(K, 4 * n);
    xyz = zeros(K, 3 * n);
    while ((~feof(file)) && (isa(t2, 'char') || (t + 1 <= t2)))
        t = t + 1;
        for i = 1:4  %  пропуск заголовков
            [~] = fgetl(file);
        end
        for j = 1:n
            line = fgetl(file);  %  считывание следующей строки
            values = str2num(line);  %  преобразование строки в числа
            qVxyz(t, 4 * j- 3:4 * j) = values([1, 5:7]);
            xyz(t, 3 * j - 2:3 * j) = values(2:4);
        end
        [~] = fgetl(file);  %  пропуск линии с тире
    end
    fclose(file);
    qVxyz = qVxyz(t1:t, :);
    xyz = xyz(t1:t, :);
end


% Возвращает число атомов, матрицы скоростей и координат

function [n, qVxyz, xyz, fs] = get_n_qVxyz_xyz_fs(filename)
    [n, qVxyz, xyz, fs] = get_matrices(filename, 1, 'end');  %  считываем данные из .irc (весь файл)
    const = 0.529177;  %  переводим боры в ангстремы
    for i = 1:n
        qVxyz(:, 4*i-2:4*i) = qVxyz(:, 4*i-2:4*i) * const;
    end
    xyz = xyz * const;
end


%  Считывает данные filename из .irc-файла и сохраняет их в бинарный файл в path_output, чтобы ускорить последующие запуски

function [n, qVxyz_full, xyz_full, fs] = load_n_qVxyz_xyz_fs(path_output, filename)
    [~, name, ~] = fileparts(filename);
    if isfile([path_output, name, '.mat'])
        load([path_output, name, '.mat'], 'n', 'qVxyz_full', 'xyz_full', 'fs');  %  если файл уже есть
    else
        [n, qVxyz_full, xyz_full, fs] = get_n_qVxyz_xyz_fs(filename);
        if (~isfolder(path_output))
            mkdir(path_output);  %  создание папки с вспомогательными файлами
        end
        save([path_output, name, '.mat'], 'n', 'qVxyz_full', 'xyz_full', 'fs');  %  сохранение данных для ускорения
        fprintf('\t%s\n\t%s\n\t%s\n', datetime('now'), 'Файл для ускорения записан по адресу:', append(path_output, name, '.mat'));
    end
end


%  Подготовливает данные для записи в ChemCraft

path_data = 'D:\MATLAB\Эффективные моды\data\';  %  папка с данными, в конце \
files = {'w3_1.irc'};  %  имена файлов

t1 = 1;  %  начало траектории
t2 = 5001;  %  конец траектории, или 'end'
t_step = 5000;  %  шаг, отсчеты

% Ниже не редактировать

sample = [cd, '\wx.sample'];

for file_id = 1:numel(files)
    filename = [path_data, files{file_id}];
    [n, qVxyz_full, xyz_full, fs] = load_n_qVxyz_xyz_fs(path_data, filename);

    [t1_id, t2_id, t_step_id] = check_t1_t2(t1, t2, t_step, size(qVxyz_full, 1), filename);
    if (t_step_id < 3*n)
        warning('\t%s\n\t%s\n\n', 'Attention!', 'Выбран интервал [t1; t2]');
    end

    q = zeros(n, 1);
    for atom = 1:n
        q(atom) = qVxyz_full(1, 4*atom-3);
    end

    for t = 0:fix((t2_id-t1_id+1)/t_step_id)-1
        t1_cur = t1_id + t * t_step_id;
        t2_cur = t1_cur + t_step_id - 1;

        if isa(t2_cur, 'double')
            qVxyz = qVxyz_full(t1_cur:t2_cur, :);
            xyz = xyz_full(t1_cur:t2_cur, :);
        end
        E12 = energy_power(qVxyz, 0.5);
        [U, S, V] = svd(E12 - mean(E12), 0);

        [~, name, ~] = fileparts(filename);
        output_path = [path_data, 'Результаты\', name, '\'];
        if (~isfolder(output_path))
            mkdir(output_path);
        end

        s = diag(S).^2 * sqrt((1e+4) / size(U, 1) / 4.1868);  %  энергия, ккал/моль
        write_wx_for_visualizer(sample, q, xyz, n, U, s, V, fs, [output_path, 'output ', num2str(t1_cur), '-', num2str(t2_cur), '.txt']);
    end
end


%  Строит график суммы под кривой Фурье-спектра по нескольким областям от времени на трех графиках

clearvars;  %  удалить все переменные
close all;  %  закрыть все графики
clc;  %  очистить вывод

threshold = 0.5;  %  доля энергии

range_3 = [5, 320;
         320, 1200;
         1200, 2000];

range_4 = range_3;
range_5 = range_3;

T_fft = 0.5e-12;  %  ширина скользящего окна, секунды

path_data = 'D:\MATLAB\Эффективные моды\data\';  %  папка с файлами, в конце символ \
path_output1 = 'D:\MATLAB\Эффективные моды\results\areas\';
path_output2 = 'D:\MATLAB\Эффективные моды\results\kinetic energy\';

files_group = {{'w3_1a.irc', 'w3_1a_1.irc', 'w3_1a_2.irc'};
               {'w3_2a.irc', 'w3_2a_1.irc', 'w3_2a_2.irc'};
               {'w3_3a.irc', 'w3_3a_1.irc', 'w3_3a_2.irc'};
               {'w3_4a.irc', 'w3_4a_1.irc', 'w3_4a_2.irc'}};

dx = 5;

keywords = {'Radial', 'Angular', 'Bending'};
markers = {'square', 'o', '^'};
colors = {'#0072BD', '#D95319', '#EDB120'};

for file_id = 1:size(files_group, 1)
    [n1, qVxyz_full1, ~, ~] = load_n_qVxyz_xyz_fs(path_data, [path_data, files_group{file_id}{1}]);  %  считываем данные из .irc
    [n2, qVxyz_full2, ~, ~] = load_n_qVxyz_xyz_fs(path_data, [path_data, files_group{file_id}{2}]);
    [n3, qVxyz_full3, ~, ~] = load_n_qVxyz_xyz_fs(path_data, [path_data, files_group{file_id}{3}]);
    min_T = min([size(qVxyz_full1, 1), size(qVxyz_full2, 1), size(qVxyz_full3, 1)]);
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    for sub_file_id = 1:size(files_group{1}, 2)
        name = files_group{file_id}{sub_file_id}(1:end-4);
        if ~((n1 == n2) && (n2 == n3))
            error(append('The numbers of atoms in the group must be the same.'));
        end
        switch n1
            case 3 * 3
                range = range_3;
            case 4 * 3
                range = range_4;
            case 5 * 3
                range = range_5;
            otherwise
                error(append(name, ' is not 3, 4 or 5 cluster. Check the frequency ranges.'));
        end
        for k = 1:size(range, 1)
            freqs_int{k} = range(k, 1):dx:range(k, 2);  %#ok<*SAGROW>
        end
        LOAD = load(append(path_data, name, '.mat'));
        n = LOAD.n;
        fs = LOAD.fs;
        qVxyz_full = LOAD.qVxyz_full;
        N_step = 100;  %  по сколько отсчетов шагаем
        N = T_fft * fs;  %  ширина интервала, отсчеты
        N_T = fix((min_T - N + 1) / N_step);  %  количество позиций
        arr = zeros(N_T, size(range, 1));  %  array of contribution values
        sing = zeros(N_T, 3 * n);
        max_fft_frq = zeros(N_T, 3 * n);
        for time_id = 1:N_T
            t = fix((1:N) + (time_id - 1) * N_step);
            E12_full = energy_power(qVxyz_full(t, :), 0.5);
            T = E12_full;
            [U, S, V] = svd(T, 0);
            s = diag(S).^2 * sqrt((1e+4) / size(U, 1) / 4.1868);  %  энергия, ккал/моль
            sing(time_id, :) = s';
            n_eff = find(cumsum(s)/sum(s) >= threshold - (1e-10), 1);
            for mode = 1:n_eff
                [freq, P1] = fourier_transform(U(:, mode)', fs);
                freq = freq / 3e+10;
                idx = zeros(size(range, 1), size(freq, 2), 'logical');
                integral = zeros(1, size(range, 1));
                for row = 1:size(range, 1)
                    idx(row, :) = ((range(row, 1) <= freq) & (freq < range(row, 2)));
                    interpolant = interp1(freq, idx(row, :) .* P1, freqs_int{row});
                    integral(row) = trapz([freqs_int{row}(1) - dx, freqs_int{row}, freqs_int{row}(end) + dx], [0, interpolant, 0], 2);
                end
                arr(time_id, :) = arr(time_id, :) + s(mode) * integral / sum(integral);  %  нормировка на квадрат сингулярного числа
            end
            arr(time_id, :) = arr(time_id, :);% / sum(arr(time_id, :));
    
            for mode = 1:3 * n
                [freq, P1] = fourier_transform(U(:, mode)', fs);
                freq = freq / 3e+10;
                max_fft_frq(time_id, mode) = get_main_freq(freq, P1);
            end
        end

        ax = subplot(3, 1, sub_file_id);
        hold(ax, 'on');
        lw = 1;
        for k = 1:size(range, 1)
            p(k) = plot(ax, (1:N_T) * N_step / N*T_fft * (1e+12), arr(:, k), 'LineWidth', lw, 'Marker', markers{k}, 'LineStyle', '-', 'MarkerSize', 6, 'Color', colors{k}, 'MarkerFaceColor', colors{k});
            labels{k} = append(keywords{k}, ' ', num2str(range(k, 1)), '-', num2str(range(k, 2)));
        end
    
        xlim(ax, [0, N_T] * N_step / N * T_fft * (1e+12));
        %ylim(ax, [0, 1]);
        
        ylabel(ax, 'E_{кин.}, ккал/моль');
        title(ax, append(name), 'Interpreter', 'None');
        %legend(ax, p, labels);
        box(ax, 'on');
        grid(ax, 'on');
        set(ax, 'FontSize', 32);
    end
    xlabel(ax, 'Время, пс');
    legend(ax, p, {'R', 'A', 'B'});

    saveas(fig, append(path_output1, files_group{file_id}{1}(1:end-4), ' + ', files_group{file_id}{2}(1:end-4), ' + ', files_group{file_id}{3}(1:end-4), ' по ', num2str(size(range, 1)), ' графика, порог ', num2str(threshold), ', доли областей.png'));
    close(fig);
end


%  Возвращает массу элемента по его заряду

function m = mass_by_charge(q)
    masses = [   1,   1.008;   2,   4.003;   3,   6.941;   4,   9.012;   5,  10.811; ...
                 6,  12.011;   7,  14.007;   8,  15.999;   9,  18.998;  10,  20.180; ...
                11,  22.990;  12,  24.305;  13,  26.982;  14,  28.086;  15,  30.974; ...
                16,  32.065;  17,  35.453;  18,  39.948;  19,  39.098;  20,  40.078; ...
                21,  44.956;  22,  47.867;  23,  50.942;  24,  51.996;  25,  54.938; ...
                26,  55.845;  27,  58.933;  28,  58.693;  29,  63.546;  30,  65.38 ; ...
                31,  69.723;  32,  72.630;  33,  74.922;  34,  78.971;  35,  79.904; ...
                36,  83.798;  37,  85.468;  38,  87.62 ;  39,  88.906;  40,  91.224; ...
                41,  92.906;  42,  95.96 ;  43,  98.907;  44, 101.07 ;  45, 102.906; ...
                46, 106.42 ;  47, 107.868;  48, 112.414;  49, 114.818;  50, 118.711; ...
                51, 121.760;  52, 127.60 ;  53, 126.905;  54, 131.294;  55, 132.905; ...
                56, 137.328;  57, 138.905;  58, 140.116;  59, 140.908;  60, 144.243; ...
                61, 144.913;  62, 150.36 ;  63, 151.964;  64, 157.25 ;  65, 158.925; ...
                66, 162.500;  67, 164.930;  68, 167.259;  69, 168.934;  70, 173.045; ...
                71, 174.967;  72, 178.49 ;  73, 180.948;  74, 183.84 ;  75, 186.207; ...
                76, 190.23 ;  77, 192.217;  78, 195.085;  79, 196.967;  80, 200.592; ...
                81, 204.383;  82, 207.2  ;  83, 208.980;  84, 208.982;  85, 209.987; ...
                86, 222.018;  87, 223.020;  88, 226.025;  89, 227.028;  90, 232.038; ...
                91, 231.036;  92, 238.029;  93, 237.048;  94, 244.064;  95, 243.061; ...
                96, 247.070;  97, 247.070;  98, 251.080;  99, 252.083; 100, 257.095; ...
               101, 258.098; 102, 259.101; 103, 262.110; 104, 267.122; 105, 268.126; ...
               106, 271.134; 107, 270.134; 108, 277.152; 109, 276.152; 110, 281.162; ...
               111, 280.164; 112, 285.174; 113, 284.178; 114, 289.187; 115, 288.192; ...
               116, 293.204; 117, 294.208; 118, 294.214 ];  %  таблица соответствия заряду массам
    m = masses(q, 2);
end


%  Решает уравнение с данными k, возвращает сумму квадратов невязки с графиком

function res = energy_kinetics(x, arr, t, const)
    %[tspan, sol] = ode15s(@(t, y) odefun_kin(t, y, k), linspace(t(1), t(end), const), arr(1, :));  %  решить уравнение
    y0 = x(7:9);  %  начальные условия
    [tspan, sol] = ode15s(@(t, y) odefun_kin(t, y, x(1:6)), linspace(t(1), t(end), const), y0);  %  решить уравнение
    y = interp1(tspan, sol, t);
    res = norm(y - arr, 'fro');
end


%  Объединяет данные файлов в один

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
temp = 'Result add 9_vars 6 order step 500 ';
file_basis = append('D:\MATLAB\Эффективные моды\scripts\', temp, '*.mat');  %  формат файлов

d = dir(file_basis);
d([d.isdir]) = [];  %  remove . and .. and all subpaths

d0 = dir(path_aux);
d0([d0.isdir]) = [];  %  remove . and .. and all subpaths
names = {d0.name}';
for idx = 1:numel(names)
    names{idx} = names{idx}(1:end-4);
end

k_best = cell(numel(d), 1);
f_vals_best = cell(numel(d), 1);
y0_best = cell(numel(d), 1);
filename = cell(numel(d), 1);

done = 0;
for file_id = 1:numel(d)
    done = done + 1;
    LOAD = load(append(d(file_id).folder, '\', d(file_id).name));
    flag = true;
    idx = 0;
    while flag
        idx = idx + 1;
        [startIndex, endIndex] = regexp(d(file_id).name, 'File\s');
        flag = ~ismember(string(d(file_id).name(endIndex+1:end-4)), names{idx});
    end
    k_best{done, 1} = LOAD.k_best{idx};
    f_vals_best{done, 1} = LOAD.f_vals_best{idx};
    y0_best{done, 1} = LOAD.y0_best{idx};
    filename{done, 1} = d(file_id).name(endIndex+1:end-4);
end

save(append(d(1).folder, '\', temp, 'all ', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), '.mat'), 'k_best', 'f_vals_best', 'filename', 'y0_best');
%save(append('D:\MATLAB\Эффективные моды\scripts\Result 9_vars 6 order step ', num2str(step), ' all 2.mat'), 'k_best', 'f_vals_best', 'filename', 'y0_best');


%  Строит график суммы и решение от времени на одном графике

clearvars;
close all;
clc;

step = 500;  %  по сколько отсчетов шагаем
const = 3e4;

LOAD = load(append('D:\MATLAB\Эффективные моды\scripts\Result add 9_vars 6 order step ', num2str(step), ' all.mat'));
path_data = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
path_output = append('D:\MATLAB\Эффективные моды\2026 Графики решений уравнения 6 порядка шаг ', num2str(step), '\');
if (~isfolder(path_output))
    mkdir(path_output);  %  создание папки с результатами
end
top = 1;

names = LOAD.filename;

for file_id = 1:numel(names)
    if ~isempty(LOAD.k_best{file_id})
        [arr, fs, range, n_eff_arr, ~] = get_arr(path_data, append(names{file_id}, '.mat'), step, false);
        t = (1:size(arr, 1)) * step / fs * (1e+12);  %  время отсчетов, пс
    
        k_best = LOAD.k_best{file_id}(top, :);
        [t_de, sol] = ode15s(@(t, y) odefun_kin(t, y, k_best), linspace(t(1), t(end), const), arr(1, :));
        fig = plot_sol(t, arr, t_de, sol, append(names{file_id}, ' распределение энергии по областям'), k_best, LOAD.f_vals_best{file_id}(top));
        exportgraphics(fig, append(path_output, names{file_id}, ' порог=', num2str(0.5), '.png'), 'Resolution', 300);
        close(fig);
    end
end


%  Рисует графики сингулярных чисел от имени файла

clearvars;
close all;
clc;

path_data = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\';
sigma_path = 'E:\MATLAB\Эффективные моды\sigma\';
path_fft = 'C:\MATLAB\Эффективные моды\Фурье\';

origs = {'I', 'II', 'III', 'IV', 'V', 'VI'};  %  идентификаторы группы

if (~isfolder(sigma_path))
    mkdir(sigma_path);
end

for series = 1:numel(origs)
    file_orig = origs{series};
    files = dir(append(path_data, 'h2o_', file_orig, '_*.mat'));  %  файлы
    files_num = zeros(1, numel(files));
    sigma = zeros(numel(files), 9);  %  3 * число атомов
    freqs = zeros(numel(files), 9);

    for file_id = 1:numel(files)
        files_num(file_id) = str2double(files(file_id).name(length(file_orig) + 6:end-4));
        LOAD = load(append(files(file_id).folder, '\', files(file_id).name));
        qVxyz_full = LOAD.qVxyz_full;
        fs = LOAD.fs;
        E12_full = energy_power(qVxyz_full, 0.5);
        T = E12_full;
        [U, S, V] = svd(T - mean(T), 0);  %  optional
        s = (diag(S)').^2 * sqrt((1e+4)/size(U, 1)/4.1868);  %  энергия, ккал/моль
        sigma(file_id, :) = s;
        for mode_id = 1:size(sigma, 2)
            [freq, P1] = fourier_transform(U(:, mode_id)', fs);
            freq = freq / 3e+10;
            freqs(file_id, mode_id) = get_main_freq(freq, P1);

            fig_fft = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
            ax_fft = axes(fig_fft);
            plot(ax_fft, freq, P1, 'LineWidth', 1.6);
            xlim(ax_fft, [0, 10000]);
            title(ax_fft, append('Фурье h2o_', origs{series}, '_', num2str(file_id), ' мода №', num2str(mode_id)), 'Interpreter', 'None');
            xlabel(ax_fft, 'Частота, см^{-1}');
            ylabel(ax_fft, 'Амплитуда на данной частоте');
            set(ax_fft, 'FontSize', 24);
            saveas(fig_fft, append(path_fft, 'Фурье h2o_', origs{series}, '_', num2str(file_id), ' мода №', num2str(mode_id), '.png'));
            close(fig_fft);
        end
    end

    %{
    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax2 = axes(fig2);
    surf(ax2, files_num, 1:size(sigmas, 2), sigmas', 'FaceAlpha', 0.5);
    xlim(ax2, files_num([1, end]));
    ylim(ax2, [1, size(sigmas, 2)]);
    zlim(ax2, [0, 10]);
    title(ax2, append('Расчет для группы h2o_', file_orig), 'Interpreter', 'None');
    xlabel(ax2, 'Имя файла');
    ylabel(ax2, 'Номер сингулярного числа k');
    zlabel(ax2, '\sigma_{k}^{2}', 'Rotation', 0);
    set(ax2, 'FontSize', 14);
    saveas(fig2, append(sigma_path, '\sigma h2o_', file_orig, '.png'));
    close(fig2);
    %}
    
    file_sigmas = fopen(append(sigma_path, 'Квадраты сингулярных чисел h2o_', origs{series}, '.txt'), 'w');
    %file_freqs = fopen(append(sigma_path, 'Частоты h2o_', origs{series}, '.txt'), 'w');
    for line = 1:size(freqs, 1)
        fprintf(file_sigmas, '%10.4f ', sigma(line, :));
        fprintf(file_sigmas, '\n');
        %fprintf(file_freqs, '%10.2f ', freqs(line, :));
        %fprintf(file_freqs, '\n');
    end
    fclose(file_sigmas);
    %fclose(file_freqs);
end


% Записывает данные в файл по шаблону wx.sample для подачи в программу-визуализатор ChemCraft

function write_wx_for_visualizer(sample, q, xyz, n, U, s, V, fs, output_file)
    file = fopen(sample, 'r');
    %output_file = append(output_path, 'output ', string(datetime(now, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH-mm-ss')), '.txt');
    file2 = fopen(output_file, 'w');
    for str_i = 1:34  %  копирование до координат, не включая их
        fprintf(file2, [insertAfter(fgetl(file), "%", "%"), '\n']);
    end
    atom_names = repmat({''}, n, 1);
    const = 0.529177;
    for str_i = 35:46
        line = fgetl(file);  %  пропуск первых 12 строк
    end
    for strout_i = 1:n  %  вставка средних координат в Борах
        x = mean(xyz(:, 3*strout_i-2))/const;
        y = mean(xyz(:, 3*strout_i-1))/const;
        z = mean(xyz(:, 3*strout_i))/const;
        atom_names{strout_i, 1} = ['a', num2str(strout_i)];
        fprintf(file2, '%3s%13.1f%17.10f%20.10f%20.10f\n', atom_names{strout_i, 1}, q(strout_i), [x, y, z]);
    end
    fgetl(file);
    fprintf(file2, '\n');
    fgetl(file);
    fprintf(file2, [' TOTAL NUMBER OF ATOMS               =   ', sprintf('%d', n), '\n']);  %  TOTAL NUMBER OF ATOMS
    for str_i = 49:52  %  копирование включая линию тире
        fprintf(file2, [fgetl(file), '\n']);
    end
    for str_i = 53:64
        line = fgetl(file);  %  пропуск вторых 12 строк
    end
    for strout_i = 1:n  %  вставка средних координат в ангстремах
        x = mean(xyz(:, 3*strout_i-2));
        y = mean(xyz(:, 3*strout_i-1));
        z = mean(xyz(:, 3*strout_i));
        fprintf(file2, '%3s%13.1f%15.10f%15.10f%15.10f\n', atom_names{strout_i, 1}, q(strout_i), [x, y, z]);
    end
    for str_i = 65:71  %  копирование до масс, не включая их
        fprintf(file2, [insertAfter(fgetl(file), "%", "%"), '\n']);
    end
    for str_i = 72:83
        line = fgetl(file);  %  пропуск третьих 12 строк
    end
    for strout_i = 1:n  %  вставка аббревиатур и масс
        m = q(strout_i);
        m = mass_by_charge(m);
        k = length(atom_names{strout_i, 1});
        fprintf(file2, ['%5s%', num2str(k), 's%', num2str(25-k), '.5f\n'], '', atom_names{strout_i, 1}, m);
    end
    for str_i = 84:87  %  копирование до FREQUENCIES  IN CM**-1, включая пустую строку
        fprintf(file2, [fgetl(file), '\n']);
    end
    for str_i = 88:165
        fgetl(file);  %  пропуск блока svd донизу
    end
    SAYVETZ = repmat({''}, 10, 1);
    for str_i = 166:175
        SAYVETZ{str_i-165, 1} = fgetl(file);  %  копирование хвоста
    end
    fclose(file);

    REDUCED_MASS = '    REDUCED MASS:      0.00000     0.00000     0.00000     0.00000     0.00000';
    step = 5;  %  максимальное число столбцов
    M = size(s, 1);
    if (s(1) >= 100)
        warning('Внимание! Сингулярное число не поместится в форматированный столбец.');
    end
    for mode = 1:step:M
        fprintf(file2, '\n');  %  пустая строка

        Flag = (mode+step <= M);  %  если надо step столбцов, то true, иначе - false
        L = Flag*step + (~Flag)*(M-mode+1);  %  текущее число столбцов
        format_n = '';
        format_fr = '';
        format_ir = '';
        format_svd = '';
        for j = 1:L
            format_n = [format_n, '%12d'];  %#ok<AGROW>
            format_fr = [format_fr, '%10.2f  '];  %#ok<AGROW>
            format_ir = [format_ir, '%12.5f'];  %#ok<AGROW>
            format_svd = [format_svd, '%12.8f'];  %#ok<AGROW>
        end

        fprintf(file2, [sprintf(['%15s', format_n], '', mode:mode+L-1) '\n']);  %  номер блока
        freqs = zeros(1, L);
        for i = 1:L
            [freq, fourier_coeffs] = fourier_transform(U(:, mode+i-1)', fs);
            freqs(1, i) = get_main_freq(freq, fourier_coeffs);
        end
        freqs = freqs / 3e+10;  %  частота в обратных сантиметрах
        fprintf(file2, ['       FREQUENCY:   ', sprintf(format_fr, freqs), '\n']);  %  FREQUENCY
        fprintf(file2, [REDUCED_MASS(1:18+12*L), '\n']);
        fprintf(file2, ['    IR INTENSITY: ', sprintf(format_ir, s(mode:mode+L-1)), '\n']);
        fprintf(file2, '\n');

        for atom = 1:n
            for comp = 'X':'Z'
                if (comp == 'X')
                    k = length(atom_names{strout_i, 1});
                    fprintf(file2, ['%3d%3s%', num2str(k), 's%', num2str(13-k), 's'], atom, '', atom_names{atom, 1}, '');
                else
                    fprintf(file2, '%19s', '');
                end
                fprintf(file2, [sprintf(['%s', format_svd], comp, V(3*(atom-1)+(comp-'X')+1, mode:mode+L-1)) '\n']);
            end
        end
        if (M - mode < step)
            fprintf(file2, '\n\n\n');
        end
        for i = 0:1
            fprintf(file2, [SAYVETZ{5*i+1, 1}, '\n']);
            for j = 2:5
                fprintf(file2, [SAYVETZ{5*i+j, 1}(1:20+12*L), '\n']);
            end
        end
    end
    fclose(file2);
    [path, name, ext] = fileparts(output_file);
    if isempty (path)
        path = append(cd, '\');
    end
    fprintf('\t%s\n\t%s\n\t%s%s%s\n', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), 'Файл для ChemCraft записан по адресу:', path, name, ext);
end