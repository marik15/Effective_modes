% Возвращает по файлу n, матрицу вида [q1, Vx1, Vy1, Vz1, q2, Vx2, Vy2, Vz2,...] и [x1, y1, z1, x2, y2, z2,...] от t1 до t2

function [n, qVxyz, xyz] = get_matrices(filename, t1, t2)
    n = count_n(filename);  %  число частиц, файл типа .irc
    file = fopen(filename);
    t = 0;  %  номер измерения
    K = 1000000;  %  число строк с запасом
    qVxyz = zeros(K, 4*n);
    xyz = zeros(K, 3*n);
    while ((~feof(file)) && (isa(t2, 'char') || (t+1 <= t2)))
        t = t + 1;
        for i = 1:4  %  пропуск заголовков
            [~] = fgetl(file);
        end
        for j = 1:n
            line = fgetl(file);  %  считывание следующей строки
            values = str2num(line);  %#ok<ST2NM>  %  преобразование строки в числа
            qVxyz(t, 4*j-3:4*j) = values([1, 5:7]);
            xyz(t, 3*j-2:3*j) = values(2:4);
        end
        [~] = fgetl(file);  %  пропуск линии с тире
    end
    fclose(file);
    qVxyz = qVxyz(t1:t, :);
    xyz = xyz(t1:t, :);
end