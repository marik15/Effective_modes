% Создаёт видеоанимацию (пока убрано) и .txt-файл с матрицами перекрываний нормальных и эффективных мод

path = 'C:\MATLAB\Эффективные моды\';  %  папка с irc-файлами, в конце символ \
files = {'w3_1.irc';
         'w3_2.irc';
         'w3_3.irc';
         'w4_1.irc';
         'w4_2.irc';
         'w4_3.irc';
         'w5_1.irc';
         'w5_2.irc';
         'w5_3.irc'};  %  имена файлов
%files = {'w5_4long.irc'};
path_normal = 'C:\MATLAB\Эффективные моды\normal_modes\';  %  папка, с файлами с нормальными модами
files_normal = {'w3.mp2';
                'w4.mp2';
                'w5.mp2'};  %  имена файлов с нормальными модами
L = 4000;  %  длина интервала в отсчетах, по которому считаем вектор
%start_arr = [1, 4001, 40001, 56001, 60001, 64001, 68001, 80001, 120001, 140001, 160001];  %  массив начал
start_arr = 1:20000:96001;
end_arr = start_arr + L - 1;  %  массив концов

% --- ниже не нужно редактировать

fs = 2E+15;  %  частота дискретизации (сколько раз в секунду пишется: половина фемтосекунды)

t1 = 1;  %  начало траектории - целое число
t2 = 'end';  %  конец траектории - целое число, либо слово 'end', если нужно посчитать до конца файла, но число строк неизвестно

for k = 1:numel(files_normal)
    filename_normal = append(path_normal, files_normal{k});
    M = read_modes(filename_normal);
    switch (size(M, 1)/(3*3))
        case 3
            w3 = M;
        case 4
            w4 = M;
        case 5
            w5 = M;
    end
end

for k = 1:numel(files)
    file = files{k};
    filename = append(path, file);
    [~, name, ~] = fileparts(filename);

    output_path_E12 = append(path, 'Вспомогательные E12-файлы\');
    if (~isfolder(output_path_E12))
        mkdir(output_path_E12);  %  создание папки с вспомогательными файлами
    end

    [n, qVxyz, ~] = get_n_qVxyz_xyz(filename);

    E12_filename = append(output_path_E12, name, '_E12.mat');
    if (~isfile(E12_filename))
        E12 = sqrt_energy(qVxyz);  %  вычисляем квадратный корень из матрицы
        save(E12_filename, 'E12');  %  сохранение данных для ускорения
        fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файл для ускорения записан по адресу:', E12_filename);
    else
        load(E12_filename);
        n = size(E12, 2)/3;
    end

    switch n/3
        case 3
            w = w3;
        case 4
            w = w4;
        case 5
            w = w5;
    end

    T = numel(start_arr) - 1;
    A = zeros(T, 3*n, 3*n);
    for t = 1:T
        [~, ~, V1] = svd(E12(start_arr(t):end_arr(t), :), 0);
        for e1 = 1:3*n
            for e2 = 1:3*n
                A(t, e1, e2) = dot(V1(:, e1), w(:, e2));
            end
        end
    end

    path_matrix = append(path, 'Матрицы сингулярные-нормальные довернутые\');
    if (~isfolder(path_matrix))
        mkdir(path_matrix);  %  создание папки с таблицами
    end
    write_overlap_matrix(abs(A), start_arr, end_arr, path_matrix, name);
end