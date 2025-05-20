%  Рисует графики сингулярных чисел от имени файла

clearvars;
close all;
clc;

path_data = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\h2\';
path_fft_graph = 'E:\MATLAB\Эффективные моды\Фурье\h2\';
path_fft = 'E:\MATLAB\Эффективные моды\Фурье\h2 txt\';

freq_upper_limit = 1e+4;  %  наибольшая частота, см^{-1}

%if (~isfolder(sigma_path))
%    mkdir(sigma_path);
%end

if (~isfolder(path_fft))
    mkdir(path_fft);
end

files = dir(append(path_data, '*.mat'));  %  файлы

for file_id = 7  %  1:numel(files)
    LOAD = load(append(files(file_id).folder, '\', files(file_id).name));
    qVxyz_full = LOAD.qVxyz_full;
    fs = LOAD.fs;
    E12_full = energy_power(qVxyz_full, 0.5);
    T = E12_full;
    [U, S, V] = svd(T - mean(T), 0);  %  optional
    s = (diag(S)')*sqrt((1e+4)/size(U, 1)/4.1868);  %  энергия, ккал/моль
    sigma = s.^2;
    freqs = zeros(1, size(sigma, 2));
    %file_fft = fopen(append(path_fft, 'Фурье ', files(file_id).name, '.txt'), 'w');
    for mode_id = 1:size(sigma, 2)
        [freq, P1] = fourier_transform(U(:, mode_id)', fs);
        freq = freq/(3e+10);
        freqs(1, mode_id) = get_main_freq(freq, P1);

        fig_fft = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
        ax_fft = axes(fig_fft);  %#ok<LAXES>
        plot(ax_fft, freq, P1, 'LineWidth', 1.6);
        xlim(ax_fft, [0, freq_upper_limit]);
        title(ax_fft, append('Фурье ', files(file_id).name, ' мода №', num2str(mode_id)), 'Interpreter', 'None');
        xlabel(ax_fft, 'Частота, см^{-1}');
        ylabel(ax_fft, 'Амплитуда на данной частоте');
        idx = (freq <= freq_upper_limit);
        main_freq = get_main_freq(freq(idx), P1(idx));
        freqs(file_id, mode_id) = main_freq;
        text(main_freq, max(P1(idx)), append('\leftarrow ', num2str(main_freq, 6)), 'FontSize', 24);
        set(ax_fft, 'FontSize', 24);
        %saveas(fig_fft, append(path_fft_graph, 'Фурье ', files(file_id).name, ' мода №', num2str(mode_id), '.png'));
        close(fig_fft);
        %fprintf(file_fft, '%8.2f %8.2f\n', main_freq, sigma(mode_id));
    end
    %fclose(file_fft);
end