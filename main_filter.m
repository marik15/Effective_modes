% Пока не фильтрует спектр и рисует графики

clearvars;
close all;
clc;

path_data = 'C:\MATLAB\Эффективные моды\';

files = {'w1_dft_1.irc';
         'w1_dft_05.irc';
         'w1_mp2_1.irc';
         'w1_mp2_05.irc'};
         %'w3_all_05.irc';
         %'w4_all_05.irc';
         %'w5_all_05.irc'};  %  файлы

t1 = 1;  %  начало траектории, отсчеты
t2 = 'end';  %  конец траектории, отсчеты, либо слово 'end', если нужно посчитать до конца файла, но число строк неизвестно
t_step = 0;  %  шаг, отсчеты
     
xlimit = 4000;  %  верхняя граница частоты, см^-1
fs = 1E+16;  %  частота дискретизации, Гц
k_mean = 11;  %  во сколько раз сжать вейвлет-картинку (ускорить работу)

L_video = 1000;
step_video = 100;

% ---

num_pages = 1;  %  количество разбиений

for file_id = 1:numel(files)
    filename = [path_data, files{file_id}];
    [~, name, ~] = fileparts(filename);
    output_path = append('C:\MATLAB\Эффективные моды\Результаты\', name, '\');  %  папка для сохранения графиков
    if (~isfolder(output_path))
        mkdir(output_path);  %  создание папки с результатами
    end
    [n, qVxyz_full, xyz_full] = load_n_qVxyz_xyz(path_data, filename);
    [t1_id, t2_id, t_step_id] = check_t1_t2(t1, t2, t_step, size(qVxyz_full, 1), filename);
    E12_full = sqrt_energy(qVxyz_full);
    for t = 0:fix((t2_id-t1_id+1)/t_step_id)-1  %  цикл по временным участочкам
        t1_cur = t1_id + t*t_step_id;
        t2_cur = t1_cur + t_step_id - 1;
        E12 = E12_full(t1_id:t2_id, :);
        T = E12;  %  .*E12;
        [U, S, V] = svd(T-mean(T), 0);
        x0 = 100*[rand-0.5, rand-0.5];
        fun = @(x) tmp_fun(x, U);
        [x, y] = fminsearch(fun, x0);
        disp(append(name, ' x = [', num2str(x), '] y = ', num2str(y)));
        for j = 1:num_pages
            k_arr = size(U, 2)/num_pages*(j-1)+1:size(U, 2)/num_pages*j;
            filename_video = append(output_path, name, ' video U for E12 Time ', num2str(t1_cur), '-', num2str(t2_cur), ' modes ', num2str(k_arr(1)), '-', num2str(k_arr(end)), '.mp4');
            %record_video_main_filter(U, fs, t1, diag(S), k_arr, filename_video, L_video, step_video);
            %[fig, fig2] = plot_fft_U(U, fs, xlimit, t1_cur-1, diag(S), k_arr);
            %saveas(fig, append(output_path, name, ' U for E12 Time ', num2str(t1_cur), '-', num2str(t2_cur), ' modes ', num2str(k_arr(1)), '-', num2str(k_arr(end)), '.png'));
            %saveas(fig2, append(output_path, name, ' Fourier for E12 Time ', num2str(t1_cur), '-', num2str(t2_cur), ' modes ', num2str(k_arr(1)), '-', num2str(k_arr(end)), '.png'));
            %close([fig, fig2]);
            %[fig3, fig4] = plot_wavelets_U(U, fs, xlimit, t1_id-1, diag(S), k_arr, k_mean);
            
            %saveas(fig4, append(output_path, name, ' wavelet for E12 Time ', num2str(t1_cur), '-', num2str(t2_cur), ' modes ', num2str(k_arr(1)), '-', num2str(k_arr(end)), '.png'));
            %close([fig3, fig4]);
            disp(append(filename, ' ', num2str(t1_cur), '-', num2str(t2_cur), ', modes ', num2str(k_arr(1)), '-', num2str(k_arr(end)), ' has been written'));
        end
    end
    disp(append(filename, ' has been written'));
end