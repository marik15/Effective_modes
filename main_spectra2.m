% Строит Фурье- и вейвлет-спектры и сохраняет их в файл

path_data = 'C:\MATLAB\Эффективные моды\';  %  папка с файлами
files = {'w5_1a.irc'};  %  файлы

modes = [1];  %  интересующие моды, диапазон можно задать так, например: 1:10
t_step = 50000;  %  шаг, отсчеты
t1 = 1;  %  начало траектории, отсчеты
t2 = 100000;  %  конец траектории, отсчеты, либо слово 'end', если нужно посчитать до конца файла, но число строк неизвестно
xlimit = 3000;  %  верхняя граница по частоте, см^-1, задаётся апостериори

fs = 2E+15;  %  частота дискретизации (сколько раз в секунду пишется: половина фемтосекунды)

% --- ниже не нужно редактировать

for k = 1:numel(files)
    filename = [path_data, files{k}];
    [filepath, name, ~] = fileparts(filename);
    [~, qVxyz_full, ~] = load_n_qVxyz_xyz(path_data, filename);

    [t1, t2] = check_t1_t2(t1, t2, size(qVxyz_full, 1));

    output_path = append(filepath, '\Результаты Фурье и вейвлеты\', name, '\');
    if (~isfolder(output_path))
        mkdir(output_path);  %  создание папки с результатами
    end

    graph_freq_P1 = cell(0);
    graph_sum_wavelet = cell(0);
    
    E12 = sqrt_energy(qVxyz_full);  %  считаем квадратный корень из матрицы
    [U, ~, ~] = svd(E12-mean(E12), 0);
    for mode_id = modes
        for t = 1:fix((t2-t1+1)/t_step)  %  цикл по временным участкам
            t1_cur = t1 + (t-1)*t_step;
            t2_cur = t1_cur + t_step - 1;
            x = t1_cur:t2_cur;
            
            fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
            ax_signal = axes(fig);
            sgtitle(fig, ['Mode №', num2str(mode_id), ', time from t_1 = ', num2str(x(1)), ' to t_2 = ', num2str(x(end))], 'FontSize', 14);
            subplot(2, 2, 1, ax_signal);
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

            ax_fft = axes(fig);
            subplot(2, 2, 2, ax_fft);
            [freq, P1] = fourier_transform(U(x, mode_id)', fs);
            freq = freq/3E+10;
            max_fft_frq = get_main_freq(freq, P1);
            plot(ax_fft, freq, P1);
            xlim(ax_fft, [0, xlimit]);
            title(ax_fft, ['Fourier transform, max at ', num2str(max_fft_frq, '%.2f'), ' cm^{-1}'], 'FontSize', 14);
            xlabel(ax_fft, 'Frequency, cm^{-1}', 'FontSize', 14);
            ylabel(ax_fft, 'Fourier coefficients', 'FontSize', 14);
            graph_freq_P1{mode_id, t} = [freq; P1]';

            ax_wavelet = axes(fig);
            subplot(2, 2, 3, ax_wavelet);
            [cfs, frq] = cwt(U(x, mode_id), fs);
            cfs = abs(cfs);
            frq = frq/3E10;  %  перевод в обратные см
            surf(ax_wavelet, x, frq, exp(cfs), 'EdgeColor', 'none', 'LineStyle', 'none', 'FaceLighting', 'phong');
            colormap(ax_wavelet, 'gray');
            view(ax_wavelet, 2);
            xlim(ax_wavelet, [x(1), x(end)]);
            ylim(ax_wavelet, [frq(end), xlimit]);
            title(ax_wavelet, 'Wavelet transform absolute values` exponent', 'FontSize', 14);
            xlabel(ax_wavelet, 'Time, count number', 'FontSize', 14);
            ylabel(ax_wavelet, 'Frequency, cm^{-1}', 'FontSize', 14);

            Pos_1 = ax_wavelet.Position;
            colorbar(ax_wavelet);
            ax_wavelet.Position = Pos_1;

            ax_sum = axes(fig);
            subplot(2, 2, 4, ax_sum);
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
            close(fig);
        end
    end

    for mode_id = modes
        fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
        ax = axes(fig2);
        xlabel(ax, 'Frequency, cm^{-1}', 'FontSize', 14);
        ylabel(ax, 'An absolute value of the Fourier transform', 'FontSize', 14);
        xlim(ax, [0, xlimit]);
        hold(ax, 'on');
        for t = 1:fix((t2-t1+1)/t_step)  %  цикл по временным участкам
            t1_cur = t1 + (t-1)*t_step;
            t2_cur = t1_cur + t_step - 1;
            p(t) = plot(ax, graph_freq_P1{mode_id, t}(:, 1), graph_freq_P1{mode_id, t}(:, 2));
            str{t} = ['От ' num2str(t1_cur), ' до ', num2str(t2_cur)];
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
        legend(ax, p, str, 'FontSize', 14);
        saveas(fig2, [output_path, 'Мода №', num2str(mode_id), ' наложение спектров.jpg']);
        close(fig2);
    end

    fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Спектры сохранены по адресу:', output_path);
end