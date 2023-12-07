% Строит векторы U и Фурье спектры каждого левого сингулярного базиса от матрицы кинетической энергии

function plot_fft_U2(t_U, t_s, labels, U, fs, xlimit, t1, s, k_arr, output_filename)
    for mode_id = k_arr
        ax_U = nexttile(t_U, mode_id);
        hold(ax_U, 'on');
        scatter(ax_U, (t1:t1+size(U, 1)-1)/fs, U(:, mode_id), 4, '.');
        xlim(ax_U, [t1, t1+size(U, 1)-1]/fs);
        title(ax_U, append('U_{', num2str(mode_id), '}: \lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        xlabel(ax_U, 'Seconds');

        ax_s = nexttile(t_s, mode_id);
        hold(ax_s, 'on');
        [freq, P1] = fourier_transform(U(:, mode_id)', fs);
        freq = freq/3E+10;  %  перевод в обратные см
        plot(ax_s, freq, P1, 'LineWidth', 1);
        xlim(ax_s, xlimit*[-0.01, 1]);
        title(ax_s, append('\lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        xlabel(ax_s, 'Frequency, cm^{-1}');
        if (mode_id == 1)
            ylabel(ax_s, 'Fourier');
            legend(flipud(ax_U.Children), labels, 'Location', 'bestoutside');
            legend(flipud(ax_s.Children), labels, 'Location', 'bestoutside');
        end

        set([ax_U, ax_s], 'FontSize', 14);
        file_output = fopen(append(output_filename, 'Мода=', num2str(mode_id), ', время ', labels{end}, '.txt'), 'w');
        for st = 1:numel(P1)
            fprintf(file_output, '%20.10f%20.10f\n', freq(st), P1(st));
        end
        fclose(file_output);
    end
end