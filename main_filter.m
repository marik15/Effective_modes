% Пока не фильтрует спектр и рисует графики

clear all;
close all;
clc;

files = {%'C:\MATLAB\Эффективные моды\w1_dft_1.irc';
         %'C:\MATLAB\Эффективные моды\w1_dft_05.irc';
         %'C:\MATLAB\Эффективные моды\w1_mp2_1.irc';
         %'C:\MATLAB\Эффективные моды\w1_mp2_05.irc'};
         %'C:\MATLAB\Эффективные моды\w3_all_05.irc';
         'C:\MATLAB\Эффективные моды\w4_all_05.irc';
         'C:\MATLAB\Эффективные моды\w5_all_05.irc'};  %  файлы

fs = 1E+16;  %  частота дискретизации, Гц
xlimit = 5000;  %  верхняя граница частоты, см^-1
t1 = 1;  %  начало
%  t2 = 10001;  %  финиш

% ---

outputpath = 'C:\MATLAB\Эффективные моды\Результаты\';  %  папка для сохранения графиков

for file_id = 1:numel(files)
    filename = files{file_id};
    [filepath, name, ~] = fileparts(filename);
    [~, qVxyz, ~] = get_n_qVxyz_xyz(filename);
    E12 = sqrt_energy(qVxyz);
    E12 = E12(t1:end, :);  %  :t2
    T = E12;  %  .*E12;
    [U, S, V] = svd(T, 0);
    for j = 1:3
        k_arr = size(U, 2)/3*(j-1)+1:size(U, 2)/3*j;
        [fig, fig2] = plot_wavelets_U(U, fs, xlimit, t1-1, diag(S), k_arr);
        saveas(fig, append(outputpath, name, ' U for E12 Time ', num2str(t1), '-', num2str(t1+size(U, 1)-1), ' modes ', num2str(k_arr(1)), '-', num2str(k_arr(end)), '.png'));
        saveas(fig2, append(outputpath, name, ' wavelet for E12 Time ', num2str(t1), '-', num2str(t1+size(U, 1)-1), ' modes ', num2str(k_arr(1)), '-', num2str(k_arr(end)), '.png'));
        close([fig, fig2]);
        disp(append(filename, ' modes ', num2str(k_arr(1)), '-', num2str(k_arr(end)), ' has been written'));
    end
    disp(append(filename, ' has been written'));
end