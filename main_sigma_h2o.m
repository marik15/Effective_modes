%  Рисует графики сингулярных чисел от имени файла

clearvars;
close all;
clc;

path_data = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\';
sigma_path = 'E:\MATLAB\Эффективные моды\sigma\';
path_fft = 'E:\MATLAB\Эффективные моды\Фурье\';

origs = {'I', 'II', 'III', 'IV', 'V', 'VI'};  %  идентификаторы группы

freq_upper_limit = 1e+4;  %  наибольшая частота, см^{-1}

if (~isfolder(sigma_path))
    mkdir(sigma_path);
end

if (~isfolder(path_fft))
    mkdir(path_fft);
end

for series = 1:numel(origs)
    file_orig = origs{series};
    files = dir(append(path_data, 'h2o_', file_orig, '_*.mat'));  %  файлы
    files_num = zeros(1, numel(files));
    sigma = zeros(numel(files), 9);  %  3 * число атомов
    freqs = zeros(numel(files), 9);

    for file_id = 1:numel(files)
        files_num(file_id) = str2double(files(file_id).name(length(file_orig) + 6:end-4));
        LOAD = load(append(files(file_id).folder, '\', files(file_id).name));
        qVxyz_full = LOAD.qVxyz_full;
        fs = LOAD.fs;
        E12_full = energy_power(qVxyz_full, 0.5);
        T = E12_full;
        [U, S, V] = svd(T - mean(T), 0);  %  optional
        s = (diag(S)')*sqrt((1e+4)/size(U, 1)/4.1868);  %  энергия, ккал/моль
        sigma(file_id, :) = s.^2;
        for mode_id = 1:size(sigma, 2)
            [freq, P1] = fourier_transform(U(:, mode_id)', fs);
            freq = freq/(3e+10);
            idx = (freq <= freq_upper_limit);
            main_freq = get_main_freq(freq(idx), P1(idx));
            freqs(file_id, mode_id) = main_freq;

            %%{
            fig_fft = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
            ax_fft = axes(fig_fft);
            plot(ax_fft, freq, P1, 'LineWidth', 1.6);
            xlim(ax_fft, [0, freq_upper_limit]);
            title(ax_fft, append('Фурье h2o_', origs{series}, '_', num2str(file_id), ' мода №', num2str(mode_id)), 'Interpreter', 'None');
            xlabel(ax_fft, 'Частота, см^{-1}');
            ylabel(ax_fft, 'Амплитуда на данной частоте');
            text(main_freq, max(P1(idx)), append('\leftarrow ', num2str(main_freq, 6)), 'FontSize', 24);
            set(ax_fft, 'FontSize', 24);
            saveas(fig_fft, append(path_fft, 'Фурье h2o_', origs{series}, '_', num2str(file_id), ' мода №', num2str(mode_id), '.png'));
            close(fig_fft);
            %%}
        end
    end

    %{
    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax2 = axes(fig2);
    surf(ax2, files_num, 1:size(sigmas, 2), sigmas', 'FaceAlpha', 0.5);
    xlim(ax2, files_num([1, end]));
    ylim(ax2, [1, size(sigmas, 2)]);
    zlim(ax2, [0, 10]);
    title(ax2, append('Расчет для группы h2o_', file_orig), 'Interpreter', 'None');
    xlabel(ax2, 'Имя файла');
    ylabel(ax2, 'Номер сингулярного числа k');
    zlabel(ax2, '\sigma_{k}^{2}', 'Rotation', 0);
    set(ax2, 'FontSize', 14);
    saveas(fig2, append(sigma_path, '\sigma h2o_', file_orig, '.png'));
    close(fig2);
    %}
    
    file_sigma = fopen(append(sigma_path, 'Квадраты сингулярных чисел h2o_', origs{series}, '.txt'), 'w');
    file_freqs = fopen(append(sigma_path, 'Частоты h2o_', origs{series}, '.txt'), 'w');
    for line = 1:size(freqs, 1)
        fprintf(file_sigma, '%10.2f ', sigma(line, :));
        fprintf(file_sigma, '\n');
        fprintf(file_freqs, '%10.2f ', freqs(line, :));
        fprintf(file_freqs, '\n');
    end
    fclose(file_sigma);
    fclose(file_freqs);
end