% Считывает данные из .irc-файла и сохраняет их в бинарный файл, чтобы ускорить следующие запуски

function [n, qVxyz_full, xyz_full] = load_n_qVxyz_xyz(path_data, filename)
    [~, name, ~] = fileparts(filename);
    output_path_tmp = append(path_data, 'Вспомогательные файлы\', name, '\');  %  fix
    if isfile([output_path_tmp, name, '.mat'])
        load([output_path_tmp, name, '.mat'], 'qVxyz_full', 'xyz_full');  %  файл есть
        n = round(size(xyz_full, 2)/3);
    else
        [n, qVxyz_full, xyz_full] = get_n_qVxyz_xyz(filename);
        if (~isfolder(output_path_tmp))
            mkdir(output_path_tmp);  %  создание папки с вспомогательными файлами
        end
        if (~isfile([output_path_tmp, name, '.mat']))
            save([output_path_tmp, name, '.mat'], 'qVxyz_full', 'xyz_full');  %  сохранение данных для ускорения
            fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файл для ускорения записан по адресу:', append(output_path_tmp, name, '.mat'));
        end
    end
    
end