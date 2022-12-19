% Программа создаёт .txt-файл для подачи в визуализатор ChemCraft

path = 'C:\MATLAB\Эффективные моды\';  %  папка с файлами, в конце символ \
files = {'w3_1.irc';
        'w4_1.irc';
        'w4_2.irc'};  %  имена файлов
L = 4000;  %  длина интервала в отсчетах, по которому считаем вектор
diff = 4000;  %  расстояние между началами первого и второго интервалов
step = 4000;  %  шаг, с которым просматриваем траекторию

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
        [N, qVxyz, ~] = get_matrices(filename, t1, t2);  %  считываем данные из .irc

        const = 0.529177;  %  переводим боры в ангстремы
        for i = 1:N
            qVxyz(:, 4*i-2:4*i) = qVxyz(:, 4*i-2:4*i)*const;
        end

        E12 = sqrt_energy(qVxyz);  %  вычисляем квадратный корень из матрицы
        save(E12_filename, 'E12');  %  сохранение данных для ускорения
        fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файл для ускорения записан по адресу:', E12_filename);
    else
        load(E12_filename);
        N = size(E12, 2)/3;
    end

    T = fix(1 + (length(E12)-(diff+L+1))/step);
    A = zeros(T, 3*N, 3*N);
    for t = 1:T
        [~, ~, V1] = svd(E12((t-1)*step+1:(t-1)*step+L, :), 0);
        [~, ~, V2] = svd(E12((t-1)*step+1+diff:(t-1)*step+1+diff+L, :), 0);
        for e1 = 1:3*N
            for e2 = 1:3*N
                A(t, e1, e2) = dot(V1(:, e1), V2(:, e2));
            end
        end
    end

    path_video = append(path, 'Видео\');
    if (~isfolder(path_video))
        mkdir(path_video);  %  создание папки с видео
    end
    draw_overlap_video(A, L, diff, step, path_video, name);
end