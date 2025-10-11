%  Добавляет подпись к каждой точке

function [txts, l, p] = add_labels(ax, t, arr, n_eff_arr)
    txts = arrayfun(@(k) text(ax, t(k), arr(k, 3) + 0.05 * diff(ylim(ax)), sprintf('%d', n_eff_arr(k)), ...
                        'Color', 'k', 'EdgeColor', 'none', 'Visible', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Margin', 1, 'FontSize', 18), ...
                        1:size(arr, 1));

    [l, p] = arrayfun(@(k) draw_arrow(ax, t(k), arr(k, 3) + 0.05 * diff(ylim(ax)), arr(k, 3)), ...
                  1:size(arr, 1));
end


%  Рисует стрелку от (x, y_start) до (x, y_end)

function [l, p] = draw_arrow(ax, x, y_start, y_end)
    %  Параметры стрелки
    line_width = 1;  %  Толщина линии
    head_length = 0.07 * diff([y_end, y_start]);  %  Длина наконечника
    head_width = line_width * 0.003 * diff(xlim(ax));  %  Ширина наконечника (в единицах данных)

    l = line(ax, [x, x], [y_start - 0.2 * diff([y_end, y_start]), y_end + head_length], 'Color', 'k', 'LineWidth', line_width);  %  Рисуем вертикальную линию

    x_tip = [x - head_width/2, x, x + head_width/2];  %  Рисуем наконечник (треугольник)
    y_tip = [y_end + head_length, y_end, y_end + head_length];
    
    p = patch(ax, x_tip, y_tip, 'k', 'EdgeColor', 'k', 'FaceColor', 'k', 'LineWidth', 0.1);
end