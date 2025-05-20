%  Строит график суммы под кривой Фурье-спектра по нескольким областям от времени на трех графиках

clearvars;
close all;
clc;

threshold = 0.5;  %  доля энергии

range_3 = [5, 320;
         320, 1200;
         1200, 2000];

range_4 = range_3;
range_5 = range_3;

T_fft = 0.5e-12;  %  ширина скользящего окна, секунды

path_aux = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\20240912\';
path_output1 = 'E:\MATLAB\Эффективные моды\results\areas\';
path_output2 = 'E:\MATLAB\Эффективные моды\results\kinetic energy\';

files_group = {{'w3_1a.mat', 'w3_1a_1.mat', 'w3_1a_2.mat'};
               {'w3_2a.mat', 'w3_2a_1.mat', 'w3_2a_2.mat'};
               {'w3_3a.mat', 'w3_3a_1.mat', 'w3_3a_2.mat'};
               {'w3_3.mat', 'w3_3_1.mat', 'w3_3_2.mat'};
               {'w4_2.mat', 'w4_2_1.mat', 'w4_2_2.mat'};
               {'w4_3.mat', 'w4_3_1.mat', 'w4_3_2.mat'};
               {'w4_2a.mat', 'w4_2a_1.mat', 'w4_2a_2.mat'};
               {'w4_2b.mat', 'w4_2b_1.mat', 'w4_2b_2.mat'}};

dx = 5;

keywords = {'Radial', 'Angular', 'Bending'};
markers = {'square', 'o', '^'};
colors = {'#0072BD', '#D95319', '#EDB120'};

for file_id = 1:size(files_group, 1)
    %LOAD_1 = load(append(path_aux, files_group{file_id}{1}));
    %LOAD_2 = load(append(path_aux, files_group{file_id}{2}));
    %LOAD_3 = load(append(path_aux, files_group{file_id}{3}));
    %min_n = min(size(LOAD_1.qVxyz_full, 1), size(LOAD_2.qVxyz_full, 1), size(LOAD_3.qVxyz_full, 1));
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    for sub_file_id = 1:3
        name = files_group{file_id}{sub_file_id};
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
        N_step = 100;  %  по сколько отсчетов шагаем
        N = T_fft*fs;  %  ширина интервала, отсчеты
        N_T = fix((size(qVxyz_full, 1) - N + 1)/N_step);  %  количество позиций
        arr = zeros(N_T, size(range, 1));  %  array of contribution values
        %  arr_sum = zeros(3, N_T, 1);  %  Sum of the singular values
        sing = zeros(N_T, 3*n);
        max_fft_frq = zeros(N_T, 3*n);
        for time_id = 1:N_T
            t = fix((1:N) + (time_id - 1) * N_step);
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
            arr(time_id, :) = arr(time_id, :)/sum(arr(time_id, :));
            %  arr_sum(time_id) = sum(s.^2);
    
            for mode = 1:3*n
                [freq, P1] = fourier_transform(U(:, mode)', fs);
                freq = freq/3E+10;
                max_fft_frq(time_id, mode) = get_main_freq(freq, P1);
            end
        end

        ax = subplot(3, 1, sub_file_id);
        hold(ax, 'on');
        lw = 1;
        for k = 1:size(range, 1)
            p(k) = plot(ax, (1:N_T)*N_step/N*T_fft*(1e+12), arr(:, k), 'LineWidth', lw, 'Marker', markers{k}, 'LineStyle', '-', 'MarkerSize', 6, 'Color', colors{k}, 'MarkerFaceColor', colors{k});
            labels{k} = append(keywords{k}, ' ', num2str(range(k, 1)), '-', num2str(range(k, 2)));
        end
    
        xlim(ax, [0, N_T]*N_step/N*T_fft*(1e+12));
        ylim(ax, [0, 1]);
        xlabel(ax, 'Время, пс');
        ylabel(ax, 'Доля');
        title(ax, append(name, ' оценка вкладов областей в спектр'), 'Interpreter', 'None');
        %legend(ax, p, labels);
        box(ax, 'on');
        grid(ax, 'on');
        set(ax, 'FontSize', 32);
    end

    saveas(fig, append(path_output1, files_group{file_id}{1}(1:end-4), ' + ', files_group{file_id}{2}(1:end-4), ' + ', files_group{file_id}{3}(1:end-4), ' по ', num2str(size(range, 1)), ' графика, порог ', num2str(threshold), ', доли областей.png'));
    close(fig);
end