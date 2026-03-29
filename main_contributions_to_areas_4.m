%  Строит график суммы под кривой Фурье-спектра по нескольким областям от времени

clearvars;
close all;
clc;

threshold = 0.5;  %  доля энергии

range_3 = [5, 320;
         320, 1200;
         1200, 2000];
%{
[5, 330;
 330, 570;
 570, 1300;
 1300, 2000];
%}
range_4 = range_3;
range_5 = range_3;

T_fft = 0.5e-12;  %  ширина скользящего окна, секунды

path_aux = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\20240912\';
path_output1 = 'E:\MATLAB\Эффективные моды\results\areas\';
path_output2 = 'E:\MATLAB\Эффективные моды\results\kinetic energy\';
%fit_path = 'E:\MATLAB\Эффективные моды\results fit\';
%freq_path = 'E:\MATLAB\Эффективные моды\Частоты\';
%raw_data_path = 'E:\MATLAB\Эффективные моды\raw data\';

files = dir(append(path_aux, '*.mat'));

dx = 5;
N_step = 500;  %  по сколько отсчетов шагаем

%{
keywords = {'Radial', 'Angular', 'Angular', 'Bending'};
markers = {'square', 'o', 'o', '^'};
colors = {'#0072BD', '#D95319', '#7E2F8E', '#EDB120'};
%}

keywords = {'Radial', 'Angular', 'Bending'};
markers = {'square', 'o', '^'};
colors = {'#0072BD', '#D95319', '#EDB120'};

for file_id = 1:numel(files)
    switch files(file_id).name(2)
        case '3'
            range = range_3;
        case '4'
            range = range_4;
        case '5'
            range = range_5;
        otherwise
            printf(append('Error: ', files(file_id).name, ' is not 3, 4 or 5 cluster. Check the frequency ranges.'));
    end
    for k = 1:size(range, 1)
        freqs_int{k} = range(k, 1):dx:range(k, 2);  %#ok<*SAGROW>
    end
    name = files(file_id).name;  %  name = replacing_names(files(file_id).name(1:end-4));
    LOAD = load(append(files(file_id).folder, '\', files(file_id).name));
    n = LOAD.n;
    fs = LOAD.fs;
    qVxyz_full = LOAD.qVxyz_full;
    N = T_fft*fs;  %  ширина интервала, отсчеты
    N_T = fix((size(qVxyz_full, 1) - N + 1)/N_step);  %  количество позиций
    arr = zeros(N_T, size(range, 1));  %  array of contribution values
    arr_sum = zeros(N_T, 1);  %  Sum of the singular values
    sing = zeros(N_T, 3*n);
    max_fft_frq = zeros(N_T, 3*n);
    %file = fopen(append(freq_path, 'Частоты ', files(file_id).name(1:end-4), '.txt'), 'w');
    for time_id = 1:N_T
        t = fix((1:N) + (time_id - 1) * N_step);
        E12_full = energy_power(qVxyz_full(t, :), 0.5);
        T = E12_full;
        [U, S, V] = svd(T, 0);
        s = diag(S).^2 * sqrt((1e+4) / size(U, 1) / 4.1868);  %  энергия, ккал/моль
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
            arr(time_id, :) = arr(time_id, :) + s(mode) * integral / sum(integral);  %  нормировка на квадрат сингулярного числа
        end
        arr(time_id, :) = arr(time_id, :)/sum(arr(time_id, :));
        arr_sum(time_id) = sum(s);

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
    %write_matrix(append(raw_data_path, 'raw data ', files(file_id).name(1:end-4), '.txt'), arr(:, 1:4), '%8.4f', 'w');
    %%{
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);  %#ok<LAXES>
    hold(ax, 'on');
    lw = 1;
    for k = 1:size(range, 1)
        p(k) = plot(ax, (1:N_T)*N_step/N*T_fft*(1e+12), arr(:, k), 'LineWidth', lw, 'Marker', markers{k}, 'LineStyle', '-', 'MarkerSize', 6, 'Color', colors{k}, 'MarkerFaceColor', colors{k});
        labels{k} = append(keywords{k}, ' ', num2str(range(k, 1)), '-', num2str(range(k, 2)));
    end
%{
    modelfun1 = @(b, x) b(1) * (1 - exp(- b(2) * x));
    start_idx = 1;
    end_idx = N_T;
    x = start_idx:end_idx;
    x_plot = linspace(x(1), x(end), 1000);
    y1 = arr(start_idx:end_idx, 1);
    beta01 = [0.5, 0.1];
    mdl1 = fitnlm(x, y1, modelfun1, beta01);
    beta1 = mdl1.Coefficients.Estimate;
    apprx1 = plot(ax, x_plot*T_fft*(1e+12), mdl1.feval(x_plot'), 'LineWidth', 2.5*lw, 'Color', p(1).Color);
    for k = 1:numel(beta1)
        str1{k} = append('c_{', num2str(k), '}=', num2str(beta1(k), 3));  %#ok<*SAGROW>
    end
    an1 = annotation(fig, 'textbox', [0.26, 0.7, 0.2, 0.2], 'String', str1, 'EdgeColor', p(1).Color, 'FontSize', 24, 'FitBoxToText', 'on');
%%{
    modelfun2 = @(b, x) b(1) * (exp(- b(2) * x) - exp(- b(3) * x));
    y2 = arr(start_idx:end_idx, 2);
    beta02 = [0.5, 0.1, 0.11];
    mdl2 = fitnlm(x, y2, modelfun2, beta02);
    beta2 = mdl2.Coefficients.Estimate;
    apprx2 = plot(ax, x_plot*T_fft*(1e+12), mdl2.feval(x_plot'), 'LineWidth', 2.5*lw, 'Color', p(2).Color);
    for k = 1:numel(beta2)
        str2{k} = append('c_{', num2str(k), '}=', num2str(beta2(k), 3));  %#ok<*SAGROW>
    end
    an2 = annotation(fig, 'textbox', [0.34, 0.7, 0.2, 0.2], 'String', str2, 'EdgeColor', p(2).Color, 'FontSize', 24, 'FitBoxToText', 'on');
%%}
%%{
    modelfun3 = @(b, x) b(1) * (exp(- b(2) * x) - exp(- b(3) * x));
    y3 = arr(start_idx:end_idx, 3);
    beta03 = [0.5, 0.1, 0.1];
    mdl3 = fitnlm(x, y3, modelfun3, beta03);
    beta3 = mdl3.Coefficients.Estimate;
    apprx3 = plot(ax, x_plot*T_fft*(1e+12), mdl3.feval(x_plot'), 'LineWidth', 2.5*lw, 'Color', p(3).Color);
    for k = 1:numel(beta3)
        str3{k} = append('c_{', num2str(k), '}=', num2str(beta3(k), 3));
    end
    an3 = annotation(fig, 'textbox', [0.432, 0.7, 0.2, 0.2], 'String', str3, 'EdgeColor', p(3).Color, 'FontSize', 24, 'FitBoxToText', 'on');
%%}
%%{
    modelfun4 = @(b, x) b(1) * exp(- b(2) * x);
    y4 = arr(start_idx:end_idx, 4);
    beta04 = [0.5, 0.1];
    mdl4 = fitnlm(x, y4, modelfun4, beta04);
    beta4 = mdl4.Coefficients.Estimate;
    apprx4 = plot(ax, x_plot*T_fft*(1e+12), mdl4.feval(x_plot'), 'LineWidth', 2.5*lw, 'Color', p(4).Color);
    for k = 1:numel(beta4)
        str3{k} = append('c_{', num2str(k), '}=', num2str(beta4(k), 3));
    end
    an4 = annotation(fig, 'textbox', [0.51, 0.7, 0.2, 0.2], 'String', str3, 'EdgeColor', p(4).Color, 'FontSize', 24, 'FitBoxToText', 'on');
%}
    xlim(ax, [0, N_T]*N_step/N*T_fft*(1e+12));
    ylim(ax, [0, 1]);
    xlabel(ax, 'Время, пс');
    ylabel(ax, 'Доля');
    title(ax, append(name, ' оценка вкладов областей в спектр'), 'Interpreter', 'None');
    legend(ax, p, labels);
    %legend(ax, [p, apprx1, apprx4], {append('Radial distortions ', num2str(range(1, 1)), '-', num2str(range(1, 2))), append('Angular distortions ', num2str(range(2, 1)), '-', num2str(range(2, 2))), append('Angular distortions ', num2str(range(3, 1)), '-', num2str(range(3, 2))), append('Bending ', num2str(range(4, 1)), '-', num2str(range(4, 2))), 'y=c_{1}(1-e^{-c_{2}x})', 'y=c_{1}e^{-c_{2}x}'}, 'Location', 'northeast', 'BackgroundAlpha', 0.5);
    %legend(ax, [p, apprx1, apprx3, apprx4], {append('Radial distortions ', num2str(range(1, 1)), '-', num2str(range(1, 2))), append('Angular distortions ', num2str(range(2, 1)), '-', num2str(range(2, 2))), append('Angular distortions ', num2str(range(3, 1)), '-', num2str(range(3, 2))), append('Bending ', num2str(range(4, 1)), '-', num2str(range(4, 2))), 'y=c_{1}(1-e^{-c_{2}x})', 'y=c_{1}(1-e^{-c_{2}x}+e^{-c_{3}x})', 'y=c_{1}e^{-c_{2}x}'}, 'Location', 'northeast');
    box(ax, 'on');
    grid(ax, 'on');
    set(ax, 'FontSize', 32);
    %%{
    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax2 = axes(fig2);  %#ok<LAXES>
    p = plot(ax2, (1:N_T)*N_step/N*T_fft*(1e+12), arr_sum, 'LineWidth', lw, 'Marker', 'o', 'MarkerSize', 6);
    ylim(ax2, [min(arr_sum), max(arr_sum)]);
    title(ax2, append(name, ' усредненная кинетическая энергия, ккал/моль'), 'Interpreter', 'None');
    xlabel(ax2, 'Время, пс');
    ylabel(ax2, append('$\sum_{k=1}^{k=3n} \sigma_{k}^{2}$'), 'Interpreter', 'latex');
    box(ax2, 'on');
    grid(ax2, 'on');
    set(ax2, 'FontSize', 32);

    saveas(fig, append(path_output1, name, ' ', num2str(size(range, 1)), ' графика, порог ', num2str(threshold), ', доли областей.png'));
    saveas(fig2, append(path_output2, name, ' ', num2str(size(range, 1)), ' графика, порог ', num2str(threshold), ', полная энергия.png'));
    close(fig);
    close(fig2);
    %%}
end