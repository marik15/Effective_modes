%  Объединяет данные файлов в один

file_basis = 'D:\MATLAB\Эффективные моды\scripts\Result 2025-06-*.mat';

d = dir(file_basis);
d([d.isdir]) = [];  %  remove . and .. and all subpaths
LOAD = load('Result 1-45 tmp.mat');
k_best = LOAD.k_best;
f_vals_best = LOAD.f_vals_best;

for file_id = 1:numel(d)
    LOAD2 = load(append(d(file_id).folder, '\', d(file_id).name));
    k_best{45 + file_id} = LOAD2.k_best{45 + file_id};
    f_vals_best{45 + file_id} = LOAD2.f_vals_best{45 + file_id};
end