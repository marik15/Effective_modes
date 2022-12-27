function A = read_modes(filename)
    file = fopen(filename, 'r');
    flag = true;
    while ((~feof(file)) && (flag))
        line = fgetl(file);
        block_index = regexp(line, 'NORMAL COORDINATE ANALYSIS IN THE HARMONIC APPROXIMATION', 'once');
        if (~isempty(block_index))
            flag = false;
        end
    end
    for str = 1:4
        fgetl(file);  %  пропуск шапки
    end
    n = 0;  %  число атомов
    flag2 = true;
    while (flag2)
        line = fgetl(file);
        atom_index = regexp(line, '\d+\s+\w+\s+\d+\.\d+', 'once');
        if (isempty(atom_index))
            flag2 = false;
        else
            n = n + 1;
        end
    end
    for str = 1:3
        fgetl(file);  %  пропуск шапки
    end
    A = zeros(n, 3*n);
    step = 5;
    for mode = 1:step:3*n
        for str = 1:5
            fgetl(file);  %  пропуск шапки таблицы
        end
        flag_row = (mode+step <= 3*n);  %  если надо step столбцов, то true, иначе - false
        L = flag_row*step + (~flag_row)*(3*n-mode+1);  %  текущее число столбцов
        for k = 1:3*n
            line = fgetl(file);
            r_id = regexp(line, '\s+.\s+\w+\s+[-]*\d{1}', 'end') - 1;
            digit_index = r_id - (line(r_id) == '-');
            A(k, mode:mode+L-1) = str2num(line(digit_index:end));  %#ok<ST2NM>
        end
        for k = 1:10
            fgetl(file);  %  пропуск низа
        end
    end
    fclose(file);
end