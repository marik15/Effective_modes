%  Заменяет ячейку в данных по новому файлу и индексу

input_name = 'D:\MATLAB\Эффективные моды\scripts\Result 9_vars 6 order step 500 all.mat';
LOAD = load(input_name);
LOAD_add = load('Result add 9_vars 6 order step 500 2025-07-29 14-11-24 File w3_2a_2.mat');
idx = 3;
idx_add = 10;
k_best_add = LOAD_add.k_best;
k_best = LOAD.k_best;
k_best{idx} = k_best_add{idx_add};
f_vals_best_add = LOAD_add.f_vals_best;
f_vals_best = LOAD.f_vals_best;
f_vals_best{idx} = f_vals_best_add{idx_add};
y0_best_add = LOAD_add.y0_best;
y0_best = LOAD.y0_best;
y0_best{idx} = y0_best_add{idx_add};
filename = LOAD.filename;

output_name = append(input_name(1:end-4), ' ', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), '.mat');
save(output_name, 'k_best', 'f_vals_best', 'filename', 'y0_best');
fprintf(1, 'Saved to: %s\n', output_name);