% Суммирует взвешенные вейвлет-спектры, и сохраняет их в файл

path_data = 'C:\MATLAB\Эффективные моды\';  %  папка с файлами
files = {'w3_4a.irc'};  %  файлы

modes = [2:3];  %  интересующие моды, диапазон можно задать так, например: 1:10
t1 = 1;  %  начало траектории, отсчеты
t2 = 'end';  %  конец траектории, отсчеты, либо слово 'end', если нужно посчитать до конца файла, но число строк неизвестно
t_step = 0;  %  шаг, отсчеты, либо число 0, чтобы посчитать всю траекторию целиком

xlimit = 4000;  %  верхняя граница по частоте, см^-1, задаётся апостериори
fs = 2E+15;  %  частота дискретизации (сколько раз в секунду пишется: половина фемтосекунды)
k_mean = 11;  %  во сколько раз сжать вейвлет-картинку (ускорить работу)

% --- ниже не нужно редактировать

for file_id = 1:numel(files)
    filename = [path_data, files{file_id}];
    [filepath, name, ~] = fileparts(filename);
    [~, qVxyz_full, ~] = load_n_qVxyz_xyz(path_data, filename);

    [t1_id, t2_id, t_step_id] = check_t1_t2(t1, t2, t_step, size(qVxyz_full, 1), filename);

    output_path = append(filepath, '\Результаты Фурье и вейвлеты\', name, '\');
    if (~isfolder(output_path))
        mkdir(output_path);  %  создание папки с результатами
    end

    graph_sum_fft = cell(0);
    graph_sum_wavelet = cell(0);
    s = cell(0);

    for mode_id = modes
        for t = 1:fix((t2_id-t1_id+1)/t_step_id)  %  цикл по временным участкам
            t1_cur = t1_id + (t-1)*t_step_id;
            t2_cur = t1_cur + t_step_id - 1;

            E12 = sqrt_energy(qVxyz_full(t1_cur:t2_cur, :));  %  считаем квадратный корень из матрицы
            [U, S, ~] = svd(E12 - mean(E12), 0);

            [freq, P1] = fourier_transform(U(:, mode_id)', fs);
            freq = freq/3E+10;
            graph_sum_fft{mode_id, t} = [freq; P1]';

            [cfs, frq] = cwt(U(:, mode_id), fs);
            cfs = abs(cfs);
            frq = frq/3E10;  %  перевод в см^-1

            wavelet_sum = sum(cfs, 2);
            graph_sum_wavelet{mode_id, t} = [frq, wavelet_sum];
            s{t} = diag(S).^(2);
        end
    end

    for t = 1:fix((t2_id-t1_id+1)/t_step_id)
        t1_cur = t1_id + (t-1)*t_step_id;
        t2_cur = t1_cur + t_step_id - 1;
        frq_fft = graph_sum_fft{modes(1), t}(:, 1);
        frq_wv = graph_sum_wavelet{modes(1), t}(:, 1);
        sum_fft = zeros(t, size(graph_sum_fft{modes(1), t}(:, 2), 1));
        sum_wv = zeros(t, size(graph_sum_wavelet{modes(1), t}(:, 2), 1));
        for mode_id = modes
            sum_wv(t, :) = sum_wv(t, :) + s{t}(mode_id)*graph_sum_wavelet{mode_id, t}(:, 2)';
            sum_fft(t, :) = sum_fft(t, :) + s{t}(mode_id)*graph_sum_fft{mode_id, t}(:, 2)';
        end
        
        fig_fft = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
        ax_sum_fft = axes(fig_fft);
        plot(ax_sum_fft, frq_fft, sum_fft);
        xlim(ax_sum_fft, [0, xlimit]);
        title(ax_sum_fft, 'График взвешенной суммы Фурье-спектров');
        xlabel(ax_sum_fft, 'Частота, см^{-1}');
        set(ax_sum_fft, 'FontSize', 14);
        saveas(fig_fft, append(output_path, name, ', время от ', num2str(t1_cur), ' до ', num2str(t2_cur), ' взвешенная сумма Фурье для Origin.png'));
        
        fig_wv = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
        ax_sum_wv = axes(fig_wv);
        plot(ax_sum_wv, frq_wv, sum_wv);
        xlim(ax_sum_wv, [0, xlimit]);
        title(ax_sum_wv, 'График взвешенной суммы вейвлет-спектров');
        xlabel(ax_sum_wv, 'Частота, см^{-1}');
        set(ax_sum_wv, 'FontSize', 14);
        saveas(fig_wv, append(output_path, name, ', время от ', num2str(t1_cur), ' до ', num2str(t2_cur), ' взвешенная сумма вейвлет для Origin.png'));

        file_ID_fft = fopen([output_path, name, ', время от ', num2str(t1_cur), ' до ', num2str(t2_cur), ' взвешенная сумма Фурье для Origin.txt'], 'w');
        file_ID_wv = fopen([output_path, name, ', время от ', num2str(t1_cur), ' до ', num2str(t2_cur), ' взвешенная сумма вейвлетов для Origin.txt'], 'w');
        for i = 1:size(graph_sum_wavelet{mode_id, t}, 1)
            fprintf(file_ID_wv, '%.10E %.10E\n', frq_fft(i), sum_fft(t, i));
            fprintf(file_ID_wv, '%.10E %.10E\n', frq_wv(i), sum_wv(t, i));
        end
        fclose(file_ID_fft);
        fclose(file_ID_wv);
    end

    fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Спектры сохранены по адресу:', output_path);
end

close(fig_fft);
close(fig_wv);