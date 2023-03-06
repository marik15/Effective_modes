% Вычисляет число молекул в системе по файлу .irc

function n = count_n(filename)
    file_tmp = fopen(filename);
    for i = 1:4  %  пропуск заголовков
        [~] = fgetl(file_tmp);
    end
    n = -1;
    flag = false;
    while (~flag)
        n = n + 1;
        line = fgetl(file_tmp);  %  считывание следующей строки
        vals = str2num(line);  %#ok<ST2NM>  %  преобразование строки в числа
        flag = isempty(vals);
    end
    fclose(file_tmp);
end
