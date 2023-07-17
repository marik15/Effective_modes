%  Вычисляет очищенные прямоугольным ядром векторы

close all;
clear all;
clc;

files = {'C:\MATLAB\Эффективные моды\w3_all_05.irc';
         'C:\MATLAB\Эффективные моды\w4_all_05.irc';
         'C:\MATLAB\Эффективные моды\w5_all_05.irc'};  %  файлы

fs = 1E+16;  %  частота дискретизации, Гц
xlimit = 4000;  %  верхняя граница частоты, см^-1
t1 = 1;  %  начало
t2 = 5001;  %  финиш
range = [120, 140];  %  диапазон фильтрации, см^-1 ???

% ---

for file_id = 1:numel(files)
    filename = files{file_id};
    [filepath, name, ~] = fileparts(filename);
    [n, qVxyz, xyz] = get_n_qVxyz_xyz(filename);
    E12 = sqrt_energy(qVxyz);
    E12 = E12(t1:t2, :);
    T = E12.*E12;
    [U, s, V] = svd(T, 0, 'vector');
    for mode_id = 1:size(U, 2)
        sig_filtered = filter_fft(U(:, mode_id)', fs, range);  %  чистые векторы
    end
end