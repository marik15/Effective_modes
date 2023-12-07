% Анализируем начало траектории

clearvars;
close all;
clc;

path_data = 'C:\MATLAB\Эффективные моды\';  %  папка с данными
output_path_fft = 'C:\MATLAB\Эффективные моды\Результаты\fft\';

files = {'w3_d1d.irc'};
         %'w3_d1a.irc';
         %'w3_d2a.irc';
         %'w3_d3a.irc';
         %'w3_d4a.irc';};  %  файлы

t1 = 1;  %  начало траектории, отсчеты
t2_arr = [500, 1000, 1500, 2000, 5000];  %  концы траекторий, отсчеты
t_step = 0;  %  шаг, отсчеты

xlimit = 5000;  %  верхняя граница частоты, см^-1
fs = 1E+16;  %  частота дискретизации, Гц
k_mean = 11;  %  во сколько раз сжать вейвлет-картинку (ускорить работу)

% ---

num_pages = 3;  %  количество разбиений

for k = 1:numel(t2_arr)
    labels{k} = append('1-', num2str(t2_arr(k)*(1E+15)/fs), ' фс');  %#ok<SAGROW>
end

for file_id = 1:numel(files)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    filename = [path_data, files{file_id}];
    [~, name, ~] = fileparts(filename);
    path_output = append('C:\MATLAB\Эффективные моды\Результаты\Стартовые колебания\', name, '\');  %  папка для сохранения графиков
    if (~isfolder(path_output))
        mkdir(path_output);  %  создание папки с результатами
    end
    [~, qVxyz_full, xyz_full] = load_n_qVxyz_xyz(path_data, filename);
    E12_full = sqrt_energy(qVxyz_full);
    k_arr = 1:size(E12_full, 2)/num_pages;
    n = length(k_arr);
    [h, w] = compute_h_w(n);
    t_U = tiledlayout(fig, h, w);
    t_s = tiledlayout(fig2, h, w);
    for k = 1:numel(t2_arr)
        t2 = t2_arr(k);
        [t1_id, t2_id, t_step_id] = check_t1_t2(t1, t2, t_step, size(qVxyz_full, 1), filename);
        t1_cur = t1_id;
        t2_cur = t1_cur + t_step_id - 1;
        E12 = E12_full(t1_id:t2_id, :);
        T = E12;  %  .*E12;
        [U, S, V] = svd(T-mean(T), 0);
        output_filename = append(output_path_fft, name, '\');
        plot_fft_U2(t_U, t_s, labels(1:k), U, fs, xlimit, t1_cur-1, diag(S), k_arr, output_filename);
    end
    saveas(fig, append(path_output, 'U Start ', name, '.png'));
    saveas(fig2, append(path_output, 'Spectra Start ', name, '.png'));
    close([fig, fig2]);
end