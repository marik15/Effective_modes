%  Строит график суммы под кривой Фурье-спектра по нескольким областям от времени на одном графике и создает видео

clearvars;
close all;
clc;

step = 500;  %  по сколько отсчетов шагаем

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
path_output = 'D:\MATLAB\Эффективные моды\Видео графики распределения энергии и долей total 2\';

files = dir(append(path_aux, '*.mat'));
files = files(~ismember({files.name}, {'.', '..'}));
keepNames = {'w3_2a.mat','w3_2a_1.mat','w3_2a_2.mat', ...
             'w3_3a.mat','w3_3a_1.mat','w3_3a_2.mat', ...
             'w3_4a.mat','w4_1b.mat','w4_1b_1.mat', 'w4_2_1.mat'};
files = files(ismember({files.name}, keepNames));  %  оставляем только некоторые файлы

for files_id = 1:1%numel(files)
    [arr, fs, range, n_eff_arr, frac, freq, fourier_coeffs_arr, freqs_int] = get_arr_fourier(path_aux, files(files_id).name, step, false);
    t = (1:size(arr, 1))*step/fs*(1e+12);  %  время отсчетов, пс

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    tile = tiledlayout(fig, 3, 1);  %  2 строки, 1 столбец
    ax_arr = nexttile(tile, 1);  %  ось с энергией (верхняя)
    ax_frac = nexttile(tile, 2);  %  ось с долей вклада (средняя)
    ax_fourier = nexttile(tile, 3);  %  ось с Фурье (нижняя)
    hold([ax_arr, ax_frac, ax_fourier], 'on');
    grid([ax_arr, ax_frac, ax_fourier], 'on');
    box([ax_arr, ax_frac, ax_fourier], 'on');
    set([ax_arr, ax_frac, ax_fourier], 'FontSize', 24);

    p = gobjects(size(range, 1), 1);
    labels = cell(size(range, 1), 1);
    for k = 1:size(range, 1)
        p(k) = plot(ax_arr, t, arr(:, k), 'LineWidth', 2, 'LineStyle', '-', 'Marker', '*');  %  , 'Color', colors{k}, 'MarkerFaceColor', colors{k}
        labels{k} = append(num2str(range(k, 1)), '-', num2str(range(k, 2)), ' см^{-1}');
    end

    xlim(ax_arr, [0, ceil(t(end))]);
    xlim(ax_fourier, [freq(1), 5000]);
    ylim_arr = ax_arr.YLim;
    ylim_frac = ax_frac.YLim;
    ylim(ax_frac, [0, 1]);
    ylim(ax_fourier, [0, 0.06]);
    set(ax_arr, 'YLim', ylim_arr);
    title(ax_arr, append(files(files_id).name(1:end-4), ' распределение энергии по областям'), 'Interpreter', 'None');
    ylabel(ax_arr, 'Энергия, ккал/моль');
    xlabel(ax_frac, 'Время, пс');
    ylabel(ax_frac, 'Доля, [0-1]');
    xlabel(ax_fourier, 'Частота, см^{-1}');
    ylabel(ax_fourier, 'Фурье');
    lgd = legend(ax_arr, p, labels, 'Location', 'bestoutside', 'AutoUpdate', 'off');

    for mode_id = 1:size(fourier_coeffs_arr, 1)
        p_frac = gobjects(size(range, 1), 1);
        for k = 1:size(range, 1)
            p_frac(k) = plot(ax_frac, t, frac(mode_id, :, k), 'Color', ax_frac.ColorOrder(k, :), 'LineWidth', 2, 'LineStyle', '-', 'Marker', '*');
        end
        title(ax_frac, append(files(files_id).name(1:end-4), ' мода ', num2str(mode_id), '/', num2str(size(frac, 1)), ', зависимость доли вклада в энергию каждой области от времени'), 'Interpreter', 'None');
        title(ax_fourier, append(files(files_id).name(1:end-4), ' мода ', num2str(mode_id), '/', num2str(size(frac, 1)), ', доли вклада в энергию каждой области (доли площадей под графиком Фурье)'), 'Interpreter', 'None');
        output_video = VideoWriter(append(path_output, files(files_id).name(1:end-4), ' мода ', num2str(mode_id), ' из ', num2str(size(frac, 1)), '.mp4'), 'MPEG-4');  %  создание видео
        output_video.FrameRate = 5;  %  кадров в секунду
        open(output_video)
        for time_id = 1:size(fourier_coeffs_arr, 2)
            if exist('l1', 'var')
                set(l1, 'XData', t([time_id, time_id]), 'YData', ylim_arr);
                set(l2, 'XData', t([time_id, time_id]), 'YData', ylim_frac);
                set(pf, 'YData', reshape(fourier_coeffs_arr(mode_id, time_id, :), 1, []));
                for area_id = 1:size(frac, 3)
                    y = interp1(freq, reshape(fourier_coeffs_arr(mode_id, time_id, :), 1, []), freqs_int{area_id});
                    set(sq(area_id), 'XData', [range(area_id, 1), freqs_int{area_id}, range(area_id, 2)], 'YData', [0, y, 0]);
                    set(txt(area_id), 'Position', [mean(range(area_id, [1, end])), -0.04 * ax_fourier.YLim(2), 0], 'String', sprintf('%.2f', frac(mode_id, time_id, area_id)));
                end
            else
                sq = gobjects(3, 1);
                txt = gobjects(3, 1);
                l1 = plot(ax_arr, t([time_id, time_id]), ylim_arr, 'Color', 'k', 'LineWidth', 1, 'LineStyle', '--');
                l2 = plot(ax_frac, t([time_id, time_id]), ax_frac.YLim, 'Color', 'k', 'LineWidth', 1, 'LineStyle', '--');
                uistack(l1, 'bottom');
                uistack(l2, 'bottom');
                pf = plot(ax_fourier, freq, reshape(fourier_coeffs_arr(mode_id, time_id, :), 1, []), 'Color', ax_frac.ColorOrder(1, :), 'LineWidth', 2, 'LineStyle', '-', 'Marker', '*');
                for area_id = 1:size(frac, 3)
                    y = interp1(freq, reshape(fourier_coeffs_arr(mode_id, time_id, :), 1, []), freqs_int{area_id});
                    sq(area_id) = patch(ax_fourier, 'XData', [range(area_id, 1), freqs_int{area_id}, range(area_id, 2)], 'YData', [0, y, 0], 'FaceColor', ax_fourier.ColorOrder(area_id, :), 'FaceAlpha', 0.3);
                    txt(area_id) = text(ax_fourier, mean(range(area_id, [1, end])), - 0.04 * ax_fourier.YLim(2), sprintf('%.2f', frac(mode_id, time_id, area_id)), 'Color', ax_fourier.ColorOrder(area_id, :), 'EdgeColor', 'none', 'Visible', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Margin', 1, 'FontSize', ax_fourier.FontSize, 'HandleVisibility', 'off');
                end
            end
            
            writeVideo(output_video, getframe(fig));
        end
        close(output_video);
        delete([l1; l2; p_frac; pf; sq; txt]);
        clear l1 l2 p_frac pf sq txt;
    end
    close(fig);
end