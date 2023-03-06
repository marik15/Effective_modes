% Определяет частоту максимальной амплитуды в спектре

function main_freq = get_main_freq(freq, P1)
    [~, max_index] = max(P1);
    main_freq = freq(max_index);
end

