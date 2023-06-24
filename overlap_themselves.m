% Создаёт видеоанимацию (пока убрано) и .txt-файл с матрицами перекрываний

path = 'C:\MATLAB\Эффективные моды\';  %  папка с irc-файлами, в конце символ \
files = {'w5_4long.irc'};  %  имена файлов
L = 4000;  %  длина интервала в отсчетах, по которому считаем вектор
start_arr = [1, 4001, 40001, 56001, 60001, 64001, 68001, 80001, 120001, 140001, 160001];  %  массив начал
end_arr = start_arr + L - 1;  %  массив концов

% --- ниже не нужно редактировать

fs = 2E+15;  %  частота дискретизации (сколько раз в секунду пишется: половина фемтосекунды)

sample = [cd, '\wx.sample'];

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

    E12_filename = append(output_path_E12, name, '_E12.mat');

    if (~isfile(E12_filename))
        [n, qVxyz, ~] = get_n_qVxyz_xyz(filename);

        E12 = sqrt_energy(qVxyz);  %  вычисляем квадратный корень из матрицы
        save(E12_filename, 'E12');  %  сохранение данных для ускорения
        fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файл для ускорения записан по адресу:', E12_filename);
    else
        load(E12_filename);
        n = size(E12, 2)/3;
    end

    T = numel(start_arr) - 1;
    A = zeros(T, 3*n, 3*n);
    for t = 1:T
        [~, ~, V1] = svd(E12(start_arr(t):end_arr(t), :), 0);
        [~, ~, V2] = svd(E12(start_arr(t+1):end_arr(t+1), :), 0);
        for e1 = 1:3*n
            for e2 = 1:3*n
                A(t, e1, e2) = dot(V1(:, e1), V2(:, e2));
            end
        end
    end

    %{
    path_video = append(path, 'Видео\');
    if (~isfolder(path_video))
        mkdir(path_video);  %  создание папки с видео
    end
    draw_overlap_video(abs(A), start_arr, end_arr, path_video, name);
    %}
    path_matrix = append(path, 'Матрицы\');
    if (~isfolder(path_matrix))
        mkdir(path_matrix);  %  создание папки с таблицами
    end
    write_overlap_matrix_themselves(abs(A), start_arr, end_arr, path_matrix, name);
end