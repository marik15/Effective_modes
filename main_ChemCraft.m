% Создаёт .txt-файл для подачи в программу-визуализатор ChemCraft

path = 'C:\MATLAB\Эффективные моды\';  %  папка с файлами, в конце символ \
files = {'w3_1.irc'};  %  имена файлов
t1 = 1;  %  начало траектории - целое число
t2 = 'end';  %  конец траектории - целое число, либо слово 'end', если нужно посчитать до конца файла, но число строк неизвестно

% ниже не нужно редактировать!

fs = 2E+15;  %  частота дискретизации (сколько раз в секунду пишется: половина фемтосекунды)

sample = [cd, '\wx.sample'];

for file_id = 1:numel(files)
    filename = [path, files{file_id}];
    [n, qVxyz, xyz] = get_n_qVxyz_xyz(filename);
    q = zeros(n, 1);
    for atom = 1:n
        q(atom) = qVxyz(1, 4*atom-3);
    end
    if (isa(t2, 'double') && (t2-t1+1 < 3*n))  %#ok<BDSCI>
        fprintf('\t%s\n\t%s\n\n', 'Внимание!', 'Длина интервала [t1; t2] меньше числа степеней свободы!');
    end

    E12 = sqrt_energy(qVxyz);  %  вычисляем квадратный корень из матрицы
    [U, S, V] = svd(E12, 0);

    [~, name, ~] = fileparts(filename);
    output_path = [path, 'Результаты\', name, '\'];
    if (~isfolder(output_path))
        mkdir(output_path);  %  создание папки с результатами
    end

    output_path_U = append(path, 'Вспомогательные файлы\', name, '\');
    if (~isfolder(output_path_U))
        mkdir(output_path_U);  %  создание папки с вспомогательными файлами
    end
    if (~isfile([output_path_U, name, '_U.mat']))
        save([output_path_U, name, '_U.mat'], 'U');  %  сохранение данных для ускорения
        fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файл для ускорения записан по адресу:', append(output_path_U, name, '_U.mat'));
    end
    write_wx_for_visualizer(sample, q, xyz, n, U, diag(S), V, fs, output_path);  %  запись в файл
end