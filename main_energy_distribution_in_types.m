%  Строит график суммы под кривой Фурье-спектра по нескольким областям от времени на одном графике

clearvars;
close all;
clc;

threshold = 0.5;  %  доля энергии

range_3 = [5, 320;
         320, 1200;
         1200, 2000];

range_4 = range_3;
range_5 = range_3;

T_width = 0.5e-12;  %  ширина скользящего окна, секунды

path_aux = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\';
path_output1 = 'E:\MATLAB\Эффективные моды\raw data\';

%{
files = dir(append(path_aux, '*.mat'));
for i = 1:numel(files)
    files_group{i}{1} = files(i).name;
end
%}

files_group = {{'w3_1.mat', 'w3_1_1.mat', 'w3_1_2.mat'};
               {'w3_1a.mat', 'w3_1a_1.mat', 'w3_1a_2.mat'};
               {'w3_2a.mat', 'w3_2a_1.mat', 'w3_2a_2.mat'};
               {'w3_3.mat', 'w3_3_1.mat', 'w3_3_2.mat'};
               {'w3_3a.mat', 'w3_3a_1.mat', 'w3_3a_2.mat'};
               {'w3_4a.mat', 'w3_4a_1.mat', 'w3_4a_2.mat'};
               {'w4_1.mat', 'w4_1_1.mat', 'w4_1_2.mat'};
               {'w4_1a.mat', 'w4_1a_1.mat', 'w4_1a_2.mat'};
               {'w4_1b.mat', 'w4_1b_1.mat', 'w4_1b_2.mat'};
               {'w4_2.mat', 'w4_2_1.mat', 'w4_2_2.mat'};
               {'w4_2a.mat', 'w4_2a_1.mat', 'w4_2a_2.mat'};
               {'w4_2b.mat', 'w4_2b_1.mat', 'w4_2b_2.mat'};  %  3.33
               {'w4_3.mat', 'w4_3_1.mat', 'w4_3_2.mat'};
               {'w4_3a.mat', 'w4_3a_1.mat', 'w4_3a_2.mat'};  %  3.33
               {'w5_2.mat', 'w5_2_1.mat', 'w5_2_2.mat'};
               {'w5_2a.mat', 'w5_2a_1.mat', 'w5_2a_2.mat'};
               {'w5_2b.mat', 'w5_2b_1.mat', 'w5_2b_2.mat'};  %  3.33
               {'w5_3.mat', 'w5_3_1.mat', 'w5_3_2.mat'};
               {'w5_3a.mat', 'w5_3a_1.mat', 'w5_3a_2.mat'}};  %  3.33

dx = 5;
step = 1000;  %  по сколько отсчетов шагаем

keywords = {'Radial', 'Angular', 'Bending'};
markers = {'square', 'o', '^'};
colors = {'#0072BD', '#D95319', '#EDB120'};

for files_id = [1:11, 13, 15:16, 18]  %  1:size(files_group, 1)  %  [12, 14, 17, 19]
    LOAD_1 = load(append(path_aux, files_group{files_id}{1}));
    LOAD_2 = load(append(path_aux, files_group{files_id}{2}));
    LOAD_3 = load(append(path_aux, files_group{files_id}{3}));
    min_n = min([size(LOAD_1.qVxyz_full, 1), size(LOAD_2.qVxyz_full, 1), size(LOAD_3.qVxyz_full, 1)]);

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);  %#ok<LAXES>
    hold(ax, 'on');
    p = [];
    labels = cell(0);
    raw_data = zeros(1 + fix((min_n - T_width*LOAD_1.fs)/(LOAD_1.fs*(1e-12))/0.5), 3 * size(files_group{files_id}, 2));
    %raw_data = zeros(1 + fix((size(LOAD_1.qVxyz_full, 1) - T_width*LOAD_1.fs)/(LOAD_1.fs*(1e-12))/0.25), 3 * size(files_group{files_id}, 2));
    for sub_file_id = 1:size(files_group{files_id}, 2)
        name = files_group{files_id}{sub_file_id};
        switch name(2)
            case '3'
                range = range_3;
            case '4'
                range = range_4;
            case '5'
                range = range_5;
            otherwise
                printf(append('Error: ', name, ' is not 3, 4 or 5 cluster. Check the frequency ranges.'));
        end
        for k = 1:size(range, 1)
            freqs_int{k} = range(k, 1):dx:range(k, 2);  %#ok<*SAGROW>
        end
        LOAD = load(append(path_aux, name));
        n = LOAD.n;
        fs = LOAD.fs;
        qVxyz_full = LOAD.qVxyz_full;

        N_width = T_width*fs;  %  ширина интервала, отсчеты
        N_steps = fix(1 + (min_n - N_width)/step);
        arr = zeros(N_steps, size(range, 1));  %  array of contribution values
        %  arr_sum = zeros(3, N_T, 1);  %  Sum of the singular values
        sing = zeros(N_steps, 3*n);
        max_fft_frq = zeros(N_steps, 3*n);
        for time_id = 1:N_steps
            t = fix((1:N_width) + (time_id - 1) * step);
            E12_full = energy_power(qVxyz_full(t, :), 0.5);
            T = E12_full;
            [U, S, V] = svd(T, 0);
            s = diag(S)*sqrt((1e+4)/size(U, 1)/4.1868);  %  энергия, ккал/моль
            sing(time_id, :) = s';
            n_eff = find(cumsum(s)/sum(s) >= threshold - (1e-10), 1);
            for mode = 1:n_eff
                [freq, P1] = fourier_transform(U(:, mode)', fs);
                freq = freq/3E+10;
                idx = zeros(size(range, 1), size(freq, 2), 'logical');
                integral = zeros(1, size(range, 1));
                for row = 1:size(range, 1)
                    idx(row, :) = ((range(row, 1) <= freq) & (freq < range(row, 2)));
                    interpolant = interp1(freq, idx(row, :).*P1, freqs_int{row});
                    integral(row) = trapz([freqs_int{row}(1) - dx, freqs_int{row}, freqs_int{row}(end) + dx], [0, interpolant, 0], 2);
                end
                arr(time_id, :) = arr(time_id, :) + (s(mode)^2)*integral/sum(integral);  %  нормировка на квадрат сингулярного числа
            end
            %  arr(time_id, :) = arr(time_id, :)/sum(arr(time_id, :));  %  нормировка на 1
            %  arr_sum(time_id) = sum(s.^2);
    
            for mode = 1:3*n
                [freq, P1] = fourier_transform(U(:, mode)', fs);
                freq = freq/3E+10;
                max_fft_frq(time_id, mode) = get_main_freq(freq, P1);
            end
        end
        
        for k = 1:size(range, 1)
            plt = plot(ax, (1:N_steps)*step/fs*(1e+12), arr(:, k), 'LineWidth', 1, 'Marker', markers{sub_file_id}, 'LineStyle', '-', 'MarkerSize', 10, 'Color', colors{k}, 'MarkerFaceColor', colors{k});
            p = [p, plt];  %#ok<*AGROW>
            lbl = append(name(1:end-4), ' ', keywords{k}, ' ', num2str(range(k, 1)), '-', num2str(range(k, 2)));
            labels = [labels, lbl];
        end
    end

    xlim(ax, [0, N_steps]*step/fs*(1e+12));
    title(ax, 'Оценка вкладов областей в спектр', 'Interpreter', 'None');
    xlabel(ax, 'Время, пс');
    ylabel(ax, 'Энергия, ккал/моль');
    l = legend(ax, p, labels, 'Location', 'north', 'Interpreter', 'None');
    box(ax, 'on');
    grid(ax, 'on');
    set(ax, 'FontSize', 24);
    exportgraphics(fig, append(path_output1, 'new ', files_group{files_id}{1}(1:end-4), ' + ', files_group{files_id}{2}(1:end-4), ' + ', files_group{files_id}{3}(1:end-4), ', 9 графиков, порог ', num2str(threshold), ', доли областей.png'), "Resolution", 300);
    close(fig);
end