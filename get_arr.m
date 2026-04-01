%  Вычисляет массив сумм под кривой Фурье-спектра по нескольким областям от времени на одном графике

function [arr, fs, range, n_eff_arr, frac] = get_arr(path_aux, filename, step, is_min)
    threshold = 0.5;  %  доля энергии
    dx = 5;  %  шаг интегрирования по частоте
    T_width = 0.5e-12;  %  ширина скользящего окна, секунды

    range_3 = [0, 225
               225, 330;
               350, 610;
               610, 800;
               800, 1100;
               1200, 2000];  %  тример

    %%{
    range_3 = [5, 320;  %  Radial
               320, 1200;  %  Angular
               1200, 2000];  %  Bending
    %%}

    range_4 = range_3;  %#ok<*NASGU>  %  тетрамер
    range_5 = range_3;  %  пентамер

    range_6 = [0, 225;
               225, 330;
               350, 610;
               610, 850;
               850, 1100;
               1200, 2000];  %  гексамер

    range_7 = [0, 225;
               225, 330;
               350, 610;
               610, 830;
               830, 1100;
               1200, 2000];  %  гептамер

    range_8 = [0, 285;
               285, 330;
               350, 610;
               610, 900;
               900, 1100;
               1200, 2000];  %  гептамер

    if is_min
        [filenames, ~] = get_similar_names(path_aux, filename);
        min_n = Inf;
        for k = 1:numel(filenames)
            LOAD(k) = load(append(path_aux, filenames{k}));  %#ok<AGROW>
            if (size(LOAD(k).qVxyz_full, 1) <= min_n)
                min_n = size(LOAD(k).qVxyz_full, 1);
            end
        end
    end

    [startIndex, endIndex] = regexp(filename, '[a-z]+\d+');
    digit = filename(regexp(filename(startIndex:endIndex), '\d+'):endIndex);
    try
        range = eval(append('range_', num2str(digit)));  %  присваиваем интервал нужных частот
    catch
        error(append('Error: ', filename, ' is not suitable cluster. Update the frequency ranges.'));
    end
    for k = 1:size(range, 1)
        freqs_int{k} = range(k, 1):dx:range(k, 2);  %#ok<AGROW>
    end
    LOAD = load(append(path_aux, filename));
    if ~is_min
        min_n = size(LOAD.qVxyz_full, 1);
    end
    n = LOAD.n;
    fs = LOAD.fs;
    qVxyz_full = LOAD.qVxyz_full;

    N_width = T_width * fs;  %  ширина скользящего окна, отсчеты
    N_steps = fix(1 + (min_n - N_width)/step);
    arr = zeros(N_steps, size(range, 1));  %  массив с энергией в данный момент
    n_eff_arr = zeros(N_steps, 1);
    frac = zeros(n, N_steps, size(range, 1));  %  массив с долей кинетической энергии в каждом диапазоне в данный момент
    for time_id = 1:N_steps
        t = fix((1:N_width) + (time_id - 1) * step);
        E12_full = energy_power(qVxyz_full(t, :), 0.5);
        T = E12_full;
        [U, S, ~] = svd(T, 0);
        s = diag(S).^2 * sqrt((1e+4) / size(U, 1) / 4.1868);  %  энергия, ккал/моль
        n_eff = find(cumsum(s)/sum(s) >= threshold - (1e-10), 1);
        n_eff_arr(time_id) = n_eff;
        for mode_id = 1:n_eff
        %for mode_id = (n_eff+1):size(U, 2)
            [freq, fourier_coeffs] = fourier_transform(U(:, mode_id)', fs);
            freq = freq/3E+10;
            idx = zeros(size(range, 1), size(freq, 2), 'logical');
            integral = zeros(1, size(range, 1));
            for row = 1:size(range, 1)
                idx(row, :) = ((range(row, 1) <= freq) & (freq < range(row, 2)));
                interpolant = interp1(freq, idx(row, :).*fourier_coeffs, freqs_int{row});
                integral(row) = trapz([freqs_int{row}(1) - dx, freqs_int{row}, freqs_int{row}(end) + dx], [0, interpolant, 0], 2);
            end
            integral_total = trapz(freq, fourier_coeffs, 2);
            arr(time_id, :) = arr(time_id, :) + s(mode_id) * integral / integral_total;  %  нормировка
            frac(mode_id, time_id, :) = integral/integral_total;
        end
    end
end