%  Вычисляет массив сумм под кривой Фурье-спектра по нескольким областям от времени на одном графике
%  arr = {r, a, b}

function [arr, fs] = get_arr(path_aux, files_group, file_id, step)
    threshold = 0.5;  %  доля энергии
    dx = 5;  %  шаг интегрирования по частоте
    T_width = 0.5e-12;  %  ширина скользящего окна, секунды

    range_3 = [5, 320;
               320, 1200;
               1200, 2000];

    range_4 = range_3;
    range_5 = range_3;

    LOAD_1 = load(append(path_aux, files_group{1}));
    LOAD_2 = load(append(path_aux, files_group{2}));
    LOAD_3 = load(append(path_aux, files_group{3}));
    min_n = min([size(LOAD_1.qVxyz_full, 1), size(LOAD_2.qVxyz_full, 1), size(LOAD_3.qVxyz_full, 1)]);

    name = files_group{file_id};
    switch name(2)
        case '3'
            range = range_3;
        case '4'
            range = range_4;
        case '5'
            range = range_5;
        otherwise
            printf(append('Error: ', name, ' is not 3, 4 or 5 cluster. Check the frequency ranges.'));
    end
    for k = 1:size(range, 1)
        freqs_int{k} = range(k, 1):dx:range(k, 2);  %#ok<AGROW>
    end
    LOAD = load(append(path_aux, name));
    n = LOAD.n;
    fs = LOAD.fs;
    qVxyz_full = LOAD.qVxyz_full;

    N_width = T_width*fs;  %  ширина интервала, отсчеты
    N_steps = fix(1 + (min_n - N_width)/step);
    arr = zeros(N_steps, size(range, 1));  %  array of contribution values
    sing = zeros(N_steps, 3*n);
    for time_id = 1:N_steps
        t = fix((1:N_width) + (time_id - 1) * step);
        E12_full = energy_power(qVxyz_full(t, :), 0.5);
        T = E12_full;
        [U, S, ~] = svd(T, 0);
        s = diag(S)*sqrt((1e+4)/size(U, 1)/4.1868);  %  энергия, ккал/моль
        sing(time_id, :) = s';
        n_eff = find(cumsum(s)/sum(s) >= threshold - (1e-10), 1);
        for mode = 1:n_eff
            [freq, P1] = fourier_transform(U(:, mode)', fs);
            freq = freq/3E+10;
            idx = zeros(size(range, 1), size(freq, 2), 'logical');
            integral = zeros(1, size(range, 1));
            for row = 1:size(range, 1)
                idx(row, :) = ((range(row, 1) <= freq) & (freq < range(row, 2)));
                interpolant = interp1(freq, idx(row, :).*P1, freqs_int{row});
                integral(row) = trapz([freqs_int{row}(1) - dx, freqs_int{row}, freqs_int{row}(end) + dx], [0, interpolant, 0], 2);
            end
            arr(time_id, :) = arr(time_id, :) + (s(mode)^2)*integral/sum(integral);  %  нормировка на квадрат сингулярного числа
        end
        %  arr(time_id, :) = arr(time_id, :)/sum(arr(time_id, :));  %  нормировка на 1
    end
end