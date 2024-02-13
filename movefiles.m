%  Перемещает файлы из подпапок в одну папку

clearvars;
close all;
clc;

origs = {'I', 'II', 'III', 'IV', 'V', 'VI'};  %  идентификаторы группы

for k = 1:numel(origs)
    file_orig = origs{k};
    path_output = append('C:\MATLAB\Эффективные моды\Результаты\h2o_', file_orig, '\');
    if (~isfolder(path_output))
        mkdir(path_output);
    end
    files = dir(append('C:\MATLAB\Эффективные моды\Результаты\*\h2o_', file_orig, '_*.png'));  %  файлы

    for id = 1:numel(files)
        movefile(append(files(id).folder, '\', files(id).name), path_output)
    end
end