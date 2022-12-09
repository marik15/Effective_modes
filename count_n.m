% Вычисляет сколько молекул в системе по файлу .irc
function N = count_n(filename)
    FILE_TMP = fopen(filename);
    for i = 1:4  %  пропуск заголовков
        [~] = fgetl(FILE_TMP);
    end
    N = -1;
    Flag = false;
    while (~Flag)
        N = N + 1;
        line = fgetl(FILE_TMP);  %  считывание следующей строки
        vals = str2num(line);  %#ok<ST2NM>  %  преобразование строки в числа
        Flag = isempty(vals);
    end
    fclose(FILE_TMP);
end
