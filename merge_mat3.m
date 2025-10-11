%  Объединяет данные файлов в один

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
temp = 'Result 9_vars 6 order step 500 ';
file_basis = append('D:\MATLAB\Эффективные моды\scripts\', temp, '*.mat');  %  формат файлов

d = dir(file_basis);
d([d.isdir]) = [];  %  remove . and .. and all subpaths

d0 = dir(path_aux);
d0([d0.isdir]) = [];  %  remove . and .. and all subpaths
names = {d0.name}';
for idx = 1:numel(names)
    names{idx} = names{idx}(1:end-4);
end

k_best = cell(numel(d), 1);
f_vals_best = cell(numel(d), 1);
y0_best = cell(numel(d), 1);
filename = cell(numel(d), 1);

done = 0;
for file_id = 1:numel(d)
    done = done + 1;
    LOAD = load(append(d(file_id).folder, '\', d(file_id).name));
    flag = true;
    idx = 0;
    while flag
        idx = idx + 1;
        [startIndex, endIndex] = regexp(d(file_id).name, 'File\s');
        flag = ~ismember(string(d(file_id).name(endIndex+1:end-4)), names{idx});
    end
    k_best{done, 1} = LOAD.k_best{idx};
    f_vals_best{done, 1} = LOAD.f_vals_best{idx};
    y0_best{done, 1} = LOAD.y0_best{idx};
    filename{done, 1} = d(file_id).name(endIndex+1:end-4);
end

save(append(d(1).folder, '\', temp, 'all ', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), '.mat'), 'k_best', 'f_vals_best', 'filename', 'y0_best');
%save(append('D:\MATLAB\Эффективные моды\scripts\Result 9_vars 6 order step ', num2str(step), ' all 2.mat'), 'k_best', 'f_vals_best', 'filename', 'y0_best');