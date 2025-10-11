%  Преобразует число в строку в экспоненциальном формате с точностью до двух знаков после запятой, заменяя стандартное обозначение e на ⋅10^{...}

function str = replaceEwith10(number)
    parts = strsplit(sprintf('%.2e', number), 'e');  %  разделяем мантиссу и порядок
    mantissa = str2double(parts{1});
    exponent = str2double(parts{2});
    if exponent
        str = sprintf('%.2f⋅10^{%d}', mantissa, exponent);  %  формируем новую строку с нужным форматом
    else
        str = sprintf('%.2f', mantissa);
    end
end