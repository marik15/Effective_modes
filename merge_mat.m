%  Объединяет данные файлов в один

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
file_basis = 'D:\MATLAB\Эффективные моды\scripts\Result 6 order 2025-07-15*.mat';  %  формат файлов
LOAD = load('Result 6 order 2025-07-15 19-36-48 File w3_2a.mat');  %  формат первого базового файла

k_best = LOAD.k_best;
f_vals_best = LOAD.f_vals_best;

d0 = dir(path_aux);
d0([d0.isdir]) = [];  %  remove . and .. and all subpaths
names = {d0.name}';
for idx = 1:numel(names)
    names{idx} = names{idx}(1:end-4);
end
d = dir(file_basis);
d([d.isdir]) = [];  %  remove . and .. and all subpaths

for file_id = 1:numel(d)
    LOAD2 = load(append(d(file_id).folder, '\', d(file_id).name));
    idx = 0;
    flag = true;
    while flag
        idx = idx + 1;
        [startIndex, endIndex] = regexp(d(file_id).name, 'File\s');
        flag = ~ismember(string(d(file_id).name(endIndex+1:end-4)), names{idx});
    end
    k_best{idx} = LOAD2.k_best{idx};
    f_vals_best{idx} = LOAD2.f_vals_best{idx};
end