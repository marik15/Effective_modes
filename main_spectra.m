% Строит Фурье- и вейвлет-спектры и сохраняет их в файл

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

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax_signal = axes(fig);
subplot(2, 2, 1, ax_signal);
ax_fft = axes(fig);
subplot(2, 2, 2, ax_fft);
ax_wv = axes(fig);
subplot(2, 2, 3, ax_wv);
ax_sum = axes(fig);
subplot(2, 2, 4, ax_sum);
fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax_overlap_fft = axes(fig2);
hold(ax_overlap_fft, 'on');
fig3 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax_overlap_wv = axes(fig3);
hold(ax_overlap_wv, 'on');
figure(fig);

for file_id = 1:numel(files)
    filename = [path_data, files{file_id}];
    [filepath, name, ~] = fileparts(filename);
    [~, qVxyz_full, ~] = load_n_qVxyz_xyz(path_data, filename);

    [t1_id, t2_id, t_step_id] = check_t1_t2(t1, t2, t_step, size(qVxyz_full, 1), filename);

    output_path = append(filepath, '\Результаты Фурье и вейвлеты\', name, '\');
    if (~isfolder(output_path))
        mkdir(output_path);  %  создание папки с результатами
    end

    graph_freq_P1 = cell(0);
    graph_sum_wavelet = cell(0);
    
    E12 = sqrt_energy(qVxyz_full);  %  считаем квадратный корень из матрицы
    [U, ~, ~] = svd(E12-mean(E12), 0);
    for mode_id = modes
        for t = 1:fix((t2_id-t1_id+1)/t_step_id)  %  цикл по временным участкам
            t1_cur = t1_id + (t-1)*t_step_id;
            t2_cur = t1_cur + t_step_id - 1;
            x = t1_cur:t2_cur;

            sgtitle(fig, ['Mode №', num2str(mode_id), ', time from t_1 = ', num2str(x(1)), ' to t_2 = ', num2str(x(end))], 'FontSize', 14);
            plot(ax_signal, x, U(x, mode_id));
            xlim(ax_signal, [x(1), x(end)]);
            if (mode_id == 1)
                th = 'st';
            elseif (mode_id == 2)
                th = 'nd';
            elseif (mode_id == 3)
                th = 'rd';
            else
                th = 'th';
            end
            title(ax_signal, ['Input signal (', num2str(mode_id), '-', th, ' vector)'], 'FontSize', 14);
            xlabel(ax_signal, 'Time, count number', 'FontSize', 14);
            ylabel(ax_signal, 'Values of the vector`s components', 'FontSize', 14);

            [freq, P1] = fourier_transform(U(x, mode_id)', fs);
            freq = freq/3E+10;
            max_fft_frq = get_main_freq(freq, P1);
            plot(ax_fft, freq, P1);
            xlim(ax_fft, [0, xlimit]);
            title(ax_fft, ['Fourier transform, max at ', num2str(max_fft_frq, '%.2f'), ' cm^{-1}'], 'FontSize', 14);
            xlabel(ax_fft, 'Frequency, cm^{-1}', 'FontSize', 14);
            ylabel(ax_fft, 'Fourier coefficients', 'FontSize', 14);
            graph_freq_P1{mode_id, t} = [freq; P1]';

            [cfs, frq] = cwt(U(x, mode_id), fs);
            cfs = abs(cfs);
            frq = frq/3E10;  %  перевод в см^-1
            x_eco = x(1):k_mean:x(end);
            z = movmean(exp(cfs), k_mean, 2);
            z_eco = zeros(size(z, 1), fix((x(end) - x(1))/k_mean) + 1);
            tmp = 1;
            while (tmp <= size(z_eco, 2))
                z_eco(:, tmp) = z(:, 1 + k_mean*(tmp-1));
                tmp = tmp + 1;
            end
            surf(ax_wv, x_eco, frq, z_eco, 'EdgeColor', 'none', 'LineStyle', 'none', 'FaceLighting', 'phong');
            colormap(ax_wv, 'gray');
            view(ax_wv, 2);
            xlim(ax_wv, [x_eco(1), x_eco(end)]);
            ylim(ax_wv, [frq(end), xlimit]);
            title(ax_wv, 'Wavelet transform absolute values` exponent', 'FontSize', 14);
            xlabel(ax_wv, 'Time, count number', 'FontSize', 14);
            ylabel(ax_wv, 'Frequency, cm^{-1}', 'FontSize', 14);

            Pos_1 = ax_wv.Position;
            colorbar(ax_wv);
            ax_wv.Position = Pos_1;

            wavelet_sum = sum(cfs, 2);
            plot(ax_sum, frq, wavelet_sum);
            xlim(ax_sum, [0, xlimit]);
            [~, max_wavelet_index] = max(wavelet_sum);
            title(ax_sum, ['Sum by rows, max at ', num2str(frq(max_wavelet_index), '%.2f'), ' cm^{-1}'], 'FontSize', 14);
            xlabel(ax_sum, 'Frequency, cm^{-1}', 'FontSize', 14);
            graph_sum_wavelet{mode_id, t} = [frq, wavelet_sum];

            an1 = annotation(fig, 'arrow', [0.48, 0.54], [0.75, 0.75]);
            an2 = annotation(fig, 'arrow', [0.2975, 0.2975], [0.5, 0.47]);
            an3 = annotation(fig, 'arrow', [0.52, 0.54], [0.28, 0.28]);
            an_a = annotation(fig, 'textbox', [0.06, 0.69, 0.1, 0.2], 'String', '(a)', 'FontSize', 14, 'EdgeColor', 'none');
            an_b = annotation(fig, 'textbox', [0.53, 0.69, 0.1, 0.2], 'String', '(b)', 'FontSize', 14, 'EdgeColor', 'none');
            an_c = annotation(fig, 'textbox', [0.06, 0.24, 0.1, 0.2], 'String', '(c)', 'FontSize', 14, 'EdgeColor', 'none');
            an_d = annotation(fig, 'textbox', [0.53, 0.24, 0.1, 0.2], 'String', '(d)', 'FontSize', 14, 'EdgeColor', 'none');
            saveas(fig, [output_path, 'Mode №', num2str(mode_id), ', t1 = ', num2str(x(1)), ', t2 = ', num2str(x(end)), '.jpg']);
        end
    end

    for mode_id = modes
        xlabel(ax_overlap_fft, 'Frequency, cm^{-1}', 'FontSize', 14);
        xlabel(ax_overlap_wv, 'Frequency, cm^{-1}', 'FontSize', 14);
        ylabel(ax_overlap_fft, 'An absolute value of the Fourier transform', 'FontSize', 14);
        ylabel(ax_overlap_wv, 'Wavelet transform absolute values` exponent', 'FontSize', 14);
        xlim(ax_overlap_fft, [0, xlimit]);
        xlim(ax_overlap_wv, [0, xlimit]);
        str = {};
        for t = 1:fix((t2_id-t1_id+1)/t_step_id)  %  цикл по временным участкам
            t1_cur = t1_id + (t-1)*t_step_id;
            t2_cur = t1_cur + t_step_id - 1;
            p_fft(t) = plot(ax_overlap_fft, graph_freq_P1{mode_id, t}(:, 1), graph_freq_P1{mode_id, t}(:, 2));  %#ok<SAGROW>
            p_wv(t) = plot(ax_overlap_wv, graph_sum_wavelet{mode_id, t}(:, 1), graph_sum_wavelet{mode_id, t}(:, 2));  %#ok<SAGROW>
            str{t} = ['От ' num2str(t1_cur), ' до ', num2str(t2_cur)];  %#ok<SAGROW>
            file_ID_fft = fopen([output_path, 'Мода №', num2str(mode_id), ', время от ', num2str(t1_cur), ' до ', num2str(t2_cur), ' график Фурье для Origin.txt'], 'w');
            for i = 1:size(graph_freq_P1{mode_id, t}, 1)
                fprintf(file_ID_fft, '%.10E %.10E\n', graph_freq_P1{mode_id, t}(i, 1), graph_freq_P1{mode_id, t}(i, 2));
            end
            fclose(file_ID_fft);
            file_ID_wavelet = fopen([output_path, 'Мода №', num2str(mode_id), ', время от ', num2str(t1_cur), ' до ', num2str(t2_cur), ' график вейвлет для Origin.txt'], 'w');
            for i = size(graph_sum_wavelet{mode_id, t}, 1):-1:1
                fprintf(file_ID_wavelet, '%.10E %.10E\n', graph_sum_wavelet{mode_id, t}(i, 1), graph_sum_wavelet{mode_id, t}(i, 2));
            end
            fclose(file_ID_wavelet);
        end
        legend(ax_overlap_fft, p_fft, str, 'FontSize', 14);
        legend(ax_overlap_wv, p_wv, str, 'FontSize', 14);
        saveas(fig2, [output_path, 'Мода №', num2str(mode_id), ' наложение Фурье-спектров.jpg']);
        saveas(fig3, [output_path, 'Мода №', num2str(mode_id), ' наложение вейвлет-спектров.jpg']);
        delete(p_fft);
        delete(p_wv);
    end

    fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Спектры сохранены по адресу:', output_path);
end

close(fig);
close(fig2);
close(fig3);