%  Строит график суммы под кривой Фурье-спектра по трем областям от времени

clearvars;
close all;
clc;

threshold = 0.5;
range_3 = [5, 320;
         320, 1200;
         1200, 2000];
range_4 = range_3;
range_5 = range_3;

%{
range_3 = [0, 315;
         320, 500;
         570, 1000;
         1500, 2000];
range_4 = [0, 315;
         410, 500;
         750, 1050;
         1500, 2000];
range_5 = [0, 315;
         410, 580;
         710, 1050;
         1500, 2000];
%}
T_fft = 0.5e-12;  %  ширина скользящего окна, секунды

path_aux = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\20240912\';
path_output1 = 'E:\MATLAB\Эффективные моды\results\areas\';
path_output2 = 'E:\MATLAB\Эффективные моды\results\kinetic energy\';
%fit_path = 'E:\MATLAB\Эффективные моды\results fit\';
%freq_path = 'E:\MATLAB\Эффективные моды\Частоты\';
%raw_data_path = 'E:\MATLAB\Эффективные моды\raw data\';

files = dir(append(path_aux, '*.mat'));

dx = 5;  %  шаг по частоте

for file_id = 1:numel(files)
    switch files(file_id).name(2)
        case '3'
            range = range_3;
        case '4'
            range = range_4;
        case '5'
            range = range_5;
    end
    freqs_int_1 = range(1, 1):dx:range(1, 2);
    freqs_int_2 = range(2, 1):dx:range(2, 2);
    freqs_int_3 = range(3, 1):dx:range(3, 2);
    name = files(file_id).name;  %  replacing_names(files(file_id).name(1:end-4));
    LOAD = load(append(files(file_id).folder, '\', files(file_id).name));
    n = LOAD.n;
    fs = LOAD.fs;
    qVxyz_full = LOAD.qVxyz_full;
    N2 = 100;  %  по сколько отсчетов шагаем
    N = T_fft*fs;  %  ширина интервала, отсчеты
    N_T = fix(size(qVxyz_full, 1)/T_fft/fs);  %  15 пс 15*2*N/N2;  %  количество позиций
    arr = zeros(N_T, 3);  %  Radial, Angular, Bending
    arr_sum = zeros(N_T, 1);  %  Sum of the singular values
    sing = zeros(N_T, 3*n);
    max_fft_frq = zeros(N_T, 3*n);
    %file = fopen(append(freq_path, 'Частоты ', files(file_id).name(1:end-4), '.txt'), 'w');
    for time_id = 1:N_T
        t = fix((1:N) + (time_id - 1) * N2);
        E12_full = energy_power(qVxyz_full(t, :), 0.5);
        T = E12_full;
        [U, S, V] = svd(T, 0);
        s = diag(S)*sqrt((1e+4)/size(U, 1)/4.1868);  %  энергия, ккал/моль
        %sing(time_id, :) = s';
        n_eff = find(cumsum(s)/sum(s) >= threshold - (1e-10), 1);
        for mode = 1:n_eff
            [freq, P1] = fourier_transform(U(:, mode)', fs);
            freq = freq/3E+10;
            idx = zeros(4, size(freq, 2), 'logical');
            integral = zeros(1, 3);
            idx(1, :) = ((range(1, 1) <= freq) & (freq < range(1, 2)));
            interpolant1 = interp1(freq, idx(1, :).*P1, freqs_int_1);
            integral(1) = trapz([freqs_int_1(1) - dx, freqs_int_1, freqs_int_1(end) + dx], [0, interpolant1, 0], 2);
            idx(2, :) = ((range(2, 1) <= freq) & (freq < range(2, 2)));
            interpolant2 = interp1(freq, idx(2, :).*P1, freqs_int_2);
            integral(2) = trapz([freqs_int_2(1) - dx, freqs_int_2, freqs_int_2(end) + dx], [0, interpolant2, 0], 2);
            idx(3, :) = ((range(3, 1) <= freq) & (freq <= range(3, 2)));
            interpolant3 = interp1(freq, idx(3, :).*P1, freqs_int_3);
            integral(3) = trapz([freqs_int_3(1) - dx, freqs_int_3, freqs_int_3(end) + dx], [0, interpolant3, 0], 2);
            arr(time_id, :) = arr(time_id, :) + (s(mode)^2)*integral/sum(integral);  %  нормировка на квадрат сингулярного числа
        end
        arr(time_id, :) = arr(time_id, :)/sum(arr(time_id, :));
        arr_sum(time_id) = sum(s.^2);

        for mode = 1:3*n
            [freq, P1] = fourier_transform(U(:, mode)', fs);
            freq = freq/3E+10;
            max_fft_frq(time_id, mode) = get_main_freq(freq, P1);
        end

        %fprintf(file, '%6.1f %4d', (time_id-1)*T_fft*(1e+12), n_eff);
        %fprintf(file, ' %8.2f', max_fft_frq(time_id, :));
        %if (time_id ~= N_T)
        %    fprintf(file, '\n');
        %end
    end
    %fclose(file);
    %write_matrix(append(raw_data_path, 'raw data ', name, '.txt'), arr(:, 1:3), '%8.4f', 'w');
    %%{
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);  %#ok<LAXES>
    hold(ax, 'on');
    lw = 1;
    p(1) = plot(ax, (1:N_T)*N2/N*(T_fft*(1e+12)), arr(:, 1), 'LineWidth', lw, 'Marker', 'square', 'LineStyle', '-', 'MarkerSize', 6, 'Color', '#0072BD', 'MarkerFaceColor', '#0072BD');
    p(2) = plot(ax, (1:N_T)*N2/N*(T_fft*(1e+12)), arr(:, 2), 'LineWidth', lw, 'Marker', 'o', 'LineStyle', '-', 'MarkerSize', 6, 'Color', '#D95319', 'MarkerFaceColor', '#D95319');
    p(3) = plot(ax, (1:N_T)*N2/N*(T_fft*(1e+12)), arr(:, 3), 'LineWidth', lw, 'Marker', '^', 'LineStyle', '-', 'MarkerSize', 6, 'Color', '#EDB120', 'MarkerFaceColor', '#EDB120');

    xlim(ax, [0, N_T]*N2/N*(T_fft*(1e+12)));
    ylim(ax, [0, 1]);
    xlabel(ax, 'Время, пс');
    ylabel(ax, 'Доля');
    title(ax, append(name, ' оценка вкладов областей в спектр'), 'Interpreter', 'None');
    legend(ax, p, {'Radial', 'Angular', 'Bending'});
    box(ax, 'on');
    grid(ax, 'on');
    set(ax, 'FontSize', 32);
    %%{
    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax2 = axes(fig2);  %#ok<LAXES>
    p = plot(ax2, (1:N_T)*N2/N*(T_fft*(1e+12)), arr_sum, 'LineWidth', lw, 'Marker', 'o', 'MarkerSize', 6);
    ylim(ax2, [min(arr_sum), max(arr_sum)]);
    title(ax2, append(name, ' усредненная кинетическая энергия, ккал/моль'), 'Interpreter', 'None');
    xlabel(ax2, 'Время, пс');
    ylabel(ax2, append('$\sum_{k=1}^{k=3n} \sigma_{k}^{2}$'), 'Interpreter', 'latex');
    box(ax2, 'on');
    grid(ax2, 'on');
    set(ax2, 'FontSize', 32);

    saveas(fig, append(path_output1, name, ' порог_', num2str(threshold), ' доля области.png'));
    saveas(fig2, append(path_output2, name, ' порог_', num2str(threshold), ' сумма квадратов.png'));
    close(fig);
    close(fig2);
    %%}
end