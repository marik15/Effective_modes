% Вычисляет сколько молекул в системе по файлу .irc
function N = count_n(filename)
    file_tmp = fopen(filename);
    for i = 1:4  %  пропуск заголовков
        [~] = fgetl(file_tmp);
    end
    N = -1;
    Flag = false;
    while (~Flag)
        N = N + 1;
        line = fgetl(file_tmp);  %  считывание следующей строки
        vals = str2num(line);  %#ok<ST2NM>  %  преобразование строки в числа
        Flag = isempty(vals);
    end
    fclose(file_tmp);
end
