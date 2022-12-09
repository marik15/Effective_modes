% Программа строит Фурье и вейвлет-спектры и сохраняет в папку

filename = 'C:\MATLAB\Эффективные моды\w3_4.irc';  %  файл
modes = [1];  %  интересующие моды, диапазон можно задать так, например: 1:10
t1 = {1:250:751};  %  начала траекторий - набор целых чисел
t2 = {250:250:1000};  %  концы траектории - набор целых чисел: размерности t1 и t2 равны
xlimit = 4000;  %  верхняя граница по частоте, см-1, задаётся апостериори

fs = 2E+15;  %  частота дискретизации (сколько раз в секунду пишется: половина фемтосекунды)

% --- ниже не нужно редактировать

[filepath, name, ~] = fileparts(filename);
if (~isfile([name, '_U.mat']))
    save_U(filename, [name, '_U.mat']);  %  сохранение данных для ускорения
end
load([name, '_U.mat']);  %  загрузка файла

output_path = [filepath, '\Результаты Фурье и вейвлеты ', name, '\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

graph_freq_P1 = cell(0);
graph_sum_wavelet = cell(0);

for mode_id = modes
    for t = 1:numel(t1{1})
        if (isa(t2{1}(t), 'char'))
            x = t1{1}(t):size(U, 1);
        else
            x = t1{1}(t):t2{1}(t);
        end
        fig = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
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
        frq = frq/3E10;
        surf(ax_wavelet, x, frq, cfs, 'EdgeColor', 'none', 'LineStyle', 'none', 'FaceLighting', 'phong');
        %colormap('jet');
        view(ax_wavelet, 2);
        xlim(ax_wavelet, [x(1), x(end)]);
        ylim(ax_wavelet, [frq(end), xlimit]);
        title(ax_wavelet, 'Wavelet transform', 'FontSize', 14);
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
    fig2 = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
    ax = axes(fig2);
    xlabel(ax, 'Frequency, cm^{-1}', 'FontSize', 14);
    ylabel(ax, 'An absolute value of the Fourier transform', 'FontSize', 14);
    xlim(ax, [0, xlimit]);
    hold(ax, 'on');
    for t = 1:numel(t1{1})
        if (isa(t2{1}(t), 'char'))
            tmpt2 = size(U, 1);
        else
            tmpt2 = t2{1}(t);
        end
        p(t) = plot(ax, graph_freq_P1{mode_id, t}(:, 1), graph_freq_P1{mode_id, t}(:, 2));
        str{t} = ['От ' num2str(t1{1}(t)), ' до ', num2str(tmpt2)];
        file_ID_fft = fopen([output_path, 'Мода №', num2str(mode_id), ', время от ', num2str(t1{1}(t)), ' до ', num2str(tmpt2), ' график Фурье для Origin.txt'], 'w');
        for i = 1:size(graph_freq_P1{mode_id, t}, 1)
            fprintf(file_ID_fft, '%.10E %.10E\n', graph_freq_P1{mode_id, t}(i, 1), graph_freq_P1{mode_id, t}(i, 2));
        end
        fclose(file_ID_fft);
        file_ID_wavelet = fopen([output_path, 'Мода №', num2str(mode_id), ', время от ', num2str(t1{1}(t)), ' до ', num2str(tmpt2), ' график вейвлет для Origin.txt'], 'w');
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