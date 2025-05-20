% Считывает данные из .irc-файла и сохраняет их в бинарный файл, чтобы ускорить следующие запуски

function [n, qVxyz_full, xyz_full, fs] = load_n_qVxyz_xyz_fs(path_output, filename)
    [~, name, ~] = fileparts(filename);
    if isfile([path_output, name, '.mat'])
        load([path_output, name, '.mat'], 'qVxyz_full', 'xyz_full', 'fs');  %  если файл уже есть
    else
        [n, qVxyz_full, xyz_full, fs] = get_n_qVxyz_xyz_fs(filename);
        if (~isfolder(path_output))
            mkdir(path_output);  %  создание папки с вспомогательными файлами
        end
        save([path_output, name, '.mat'], 'n', 'qVxyz_full', 'xyz_full', 'fs');  %  сохранение данных для ускорения
        fprintf('\t%s\n\t%s\n\t%s\n', datetime('now'), 'Файл для ускорения записан по адресу:', append(path_output, name, '.mat'));
    end
end