% Возвращает матрицу вида [q1 Vx1 Vy1 Vz1 q2 Vx2 Vy2 Vz2...] от t1 до t2
function [N, qVxyz, xyz] = get_matrices(filename, t1, t2)
    N = count_n(filename);  %  число частиц, файл типа .irc
    FILE = fopen(filename);
    t = 0;  %  номер измерения
    K = 1000000;  %  число строк с запасом
    qVxyz = zeros(K, 4*N);
    xyz = zeros(K, 3*N);
    while ((~feof(FILE)) && (isa(t2, 'char') || (t+1 <= t2)))
        t = t + 1;
        for i = 1:4  %  пропуск заголовков
            [~] = fgetl(FILE);
        end
        for j = 1:N
            line = fgetl(FILE);  %  считывание следующей строки
            Values = str2num(line);  %#ok<ST2NM>  %  преобразование строки в числа
            qVxyz(t, 4*j-3:4*j) = Values([1, 5:7]);
            xyz(t, 3*j-2:3*j) = Values(2:4);
        end
        [~] = fgetl(FILE);  %  пропуск линии с тире
    end
    fclose(FILE);
    qVxyz = qVxyz(t1:t, :);
    xyz = xyz(t1:t, :);
end