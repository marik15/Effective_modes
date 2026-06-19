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


% Возвращает число атомов, матрицы скоростей и координат

function [n, qVxyz, xyz, fs] = get_n_qVxyz_xyz_fs(filename)
    [n, qVxyz, xyz, fs] = get_matrices(filename, 1, 'end');  %  считываем данные из .irc (весь файл)
    const = 0.529177;  %  переводим боры в ангстремы
    for i = 1:n
        qVxyz(:, 4*i-2:4*i) = qVxyz(:, 4*i-2:4*i) * const;
    end
    xyz = xyz * const;
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


% Определяет частоту максимальной амплитуды в спектре

function main_freq = get_main_freq(freq, P1)
    [~, max_index] = max(P1);
    main_freq = freq(max_index);
end