%  Строит график суммы под кривой Фурье-спектра по нескольким областям от времени на трех графиках

clearvars;  %  удалить все переменные
close all;  %  закрыть все графики
clc;  %  очистить вывод

range_3 = [5, 320;
         320, 1200;
         1200, 2000];

range_4 = range_3;
range_5 = range_3;

T_fft = 0.5e-12;  %  ширина скользящего окна, секунды

path_data = 'D:\MATLAB\Эффективные моды\data\';  %  папка с файлами, в конце символ \
path_output1 = 'D:\MATLAB\Эффективные моды\results\areas\';
path_output2 = 'D:\MATLAB\Эффективные моды\results\kinetic energy\';

files_group = {{'w3_1a.irc', 'w3_1a_1.irc', 'w3_1a_2.irc'};
               {'w3_2a.irc', 'w3_2a_1.irc', 'w3_2a_2.irc'};
               {'w3_3a.irc', 'w3_3a_1.irc', 'w3_3a_2.irc'};
               {'w3_4a.irc', 'w3_4a_1.irc', 'w3_4a_2.irc'}};

dx = 5;

k_kkal_mole = 627.5095;  %  коэффициент перевода а.е.м. * (бор/фс)^2 в ккал/моль: E = 0.5 * k * m * V^2;

keywords = {'Radial', 'Angular', 'Bending'};
markers = {'square', 'o', '^'};
colors = {'#0072BD', '#D95319', '#EDB120'};

for file_id = 1:size(files_group, 1)
    [n1, qVxyz_full1, ~, ~] = load_n_qVxyz_xyz_fs(path_data, [path_data, files_group{file_id}{1}]);  %  считываем данные из .irc
    [n2, qVxyz_full2, ~, ~] = load_n_qVxyz_xyz_fs(path_data, [path_data, files_group{file_id}{2}]);
    [n3, qVxyz_full3, ~, ~] = load_n_qVxyz_xyz_fs(path_data, [path_data, files_group{file_id}{3}]);
    min_T = min([size(qVxyz_full1, 1), size(qVxyz_full2, 1), size(qVxyz_full3, 1)]);
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    for sub_file_id = 1:size(files_group{1}, 2)
        name = files_group{file_id}{sub_file_id}(1:end-4);
        if ~((n1 == n2) && (n2 == n3))
            error(append('The numbers of atoms in the group must be the same.'));
        end
        switch n1
            case 3 * 3
                range = range_3;
            case 4 * 3
                range = range_4;
            case 5 * 3
                range = range_5;
            otherwise
                error(append(name, ' is not 3, 4 or 5 cluster. Check the frequency ranges.'));
        end
        for k = 1:size(range, 1)
            freqs_int{k} = range(k, 1):dx:range(k, 2);  %#ok<*SAGROW>
        end
        LOAD = load(append(path_data, name, '.mat'));
        n = LOAD.n;
        fs = LOAD.fs;
        qVxyz_full = LOAD.qVxyz_full;
        N_step = 100;  %  по сколько отсчетов шагаем
        N = T_fft * fs;  %  ширина интервала, отсчеты
        N_T = fix((min_T - N + 1) / N_step);  %  количество позиций
        arr = zeros(N_T, size(range, 1));  %  array of contribution values
        sing = zeros(N_T, 3 * n);
        max_fft_frq = zeros(N_T, 3 * n);
        for time_id = 1:N_T
            t = fix((1:N) + (time_id - 1) * N_step);
            E12_full = energy_power(qVxyz_full(t, :), 0.5);
            T = E12_full;
            [U, S, V] = svd(T, 0);
            s = diag(S).^2 / size(U, 1) * k_kkal_mole;  %  энергия, ккал/моль
            sing(time_id, :) = s';
            N_eff = count_N_eff(s);
            for mode = 1:N_eff
                [freq, P1] = fourier_transform(U(:, mode)', fs);
                freq = freq / 3e+10;
                idx = zeros(size(range, 1), size(freq, 2), 'logical');
                integral = zeros(1, size(range, 1));
                for row = 1:size(range, 1)
                    idx(row, :) = ((range(row, 1) <= freq) & (freq < range(row, 2)));
                    interpolant = interp1(freq, idx(row, :) .* P1, freqs_int{row});
                    integral(row) = trapz([freqs_int{row}(1) - dx, freqs_int{row}, freqs_int{row}(end) + dx], [0, interpolant, 0], 2);
                end
                arr(time_id, :) = arr(time_id, :) + s(mode) * integral / sum(integral);  %  нормировка на квадрат сингулярного числа
            end
            arr(time_id, :) = arr(time_id, :);% / sum(arr(time_id, :));
    
            for mode = 1:3 * n
                [freq, P1] = fourier_transform(U(:, mode)', fs);
                freq = freq / 3e+10;
                max_fft_frq(time_id, mode) = get_main_freq(freq, P1);
            end
        end

        ax = subplot(3, 1, sub_file_id);
        hold(ax, 'on');
        lw = 1;
        for k = 1:size(range, 1)
            p(k) = plot(ax, (1:N_T) * N_step / N*T_fft * (1e+12), arr(:, k), 'LineWidth', lw, 'Marker', markers{k}, 'LineStyle', '-', 'MarkerSize', 6, 'Color', colors{k}, 'MarkerFaceColor', colors{k});
            labels{k} = append(keywords{k}, ' ', num2str(range(k, 1)), '-', num2str(range(k, 2)));
        end
    
        xlim(ax, [0, N_T] * N_step / N * T_fft * (1e+12));
        %ylim(ax, [0, 1]);
        
        ylabel(ax, 'E_{кин.}, ккал/моль');
        title(ax, append(name), 'Interpreter', 'None');
        %legend(ax, p, labels);
        box(ax, 'on');
        grid(ax, 'on');
        set(ax, 'FontSize', 32);
    end
    xlabel(ax, 'Время, пс');
    legend(ax, p, {'R', 'A', 'B'});

    saveas(fig, append(path_output1, files_group{file_id}{1}(1:end-4), ' + ', files_group{file_id}{2}(1:end-4), ' + ', files_group{file_id}{3}(1:end-4), ' по ', num2str(size(range, 1)), ' графика, порог ', num2str(threshold), ', доли областей.png'));
    close(fig);
end