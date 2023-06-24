% Возвращает оптимальное число строк и столбцов для рисования n графиков

function [h, w] = compute_h_w(n)
    tmp = get(0, 'MonitorPositions');
    aspect_ratio = tmp(3)/tmp(4);  %  aspect ratio, 16:9
    F = factor(n);
    best_loss = inf;
    for k = 1:2^(length(F))-1
        mask = dec2bin(k, length(F));
        h1 = prod(F(mask == '0'));
        w1 = prod(F(mask == '1'));
        cur_loss = abs(w1/h1 - aspect_ratio);
        if (cur_loss <= best_loss)
            h = h1;
            w = w1;
            best_loss = cur_loss;
        end
    end
end