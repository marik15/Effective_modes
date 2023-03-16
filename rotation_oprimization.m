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
L = 2000;  %  длина интервала в отсчетах, по которому считаем вектор
%start_arr = [1, 4001, 40001, 56001, 60001, 64001, 68001, 80001, 120001, 140001, 160001];  %  массив начал
start_arr = 1:L:100001 - L + 1;
end_arr = start_arr + L - 1;  %  массив концов

% --- ниже не нужно редактировать

fs = 2E+15;  %  частота дискретизации (сколько раз в секунду пишется: половина фемтосекунды)

t1 = 1;  %  начало траектории - целое число
t2 = 'end';  %  конец траектории - целое число, либо слово 'end', если нужно посчитать до конца файла, но число строк неизвестно

for k = 1:numel(files)
    file = files{k};
    filename = append(path, file);
    [~, name, ~] = fileparts(filename);

    output_path_E12 = append(path, 'Вспомогательные E12-файлы\');
    if (~isfolder(output_path_E12))
        mkdir(output_path_E12);  %  создание папки с вспомогательными файлами
    end

    [n, qVxyz, xyz] = get_matrices(filename, t1, t2);  %  считываем данные из .irc
    const = 0.529177;  %  переводим боры в ангстремы
    for i = 1:n
        qVxyz(:, 4*i-2:4*i) = qVxyz(:, 4*i-2:4*i)*const;
    end
    tmp_m = get_mass(qVxyz);
    m = zeros(1, 3*n);
    for atom = 1:n
        m(3*atom-2:3*atom) = tmp_m(atom);
    end

    E12_filename = append(output_path_E12, name, '_E12.mat');
    if (~isfile(E12_filename))
        E12 = sqrt_energy(qVxyz);  %  вычисляем квадратный корень из матрицы
        save(E12_filename, 'E12');  %  сохранение данных для ускорения
        fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файл для ускорения записан по адресу:', E12_filename);
    else
        load(E12_filename);
    end

    angle = zeros(1+numel(start_arr), 3);
    for t = 1:numel(start_arr)
        r0 = xyz(1, :);
        r1 = mean(xyz(start_arr(t):end_arr(t), :));  %  усреднение
        alpha_init = angle(t, :);
        angle_cur = rotate_system(m, r1, r0, alpha_init);
        angle(t+1, :) = angle_cur;
    end
end