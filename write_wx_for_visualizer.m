% Меняет данные файла wx.sample для подачи в программу-визуализатор
function write_wx_for_visualizer(sample, q, xyz, N, U, s, V, fs, output_path)
    file = fopen(sample, 'r');
    %output_file = append(output_path, 'output ', string(datetime(now, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH-mm-ss')), '.txt');
    output_file = [output_path, 'output.txt'];
    file2 = fopen(output_file, 'w');
    for str_i = 1:34  %  копирование до координат, не включая их
        fprintf(file2, [insertAfter(fgetl(file), "%", "%"), '\n']);
    end
    atom_names = repmat({''}, N, 1);
    const = 0.529177;
    for str_i = 35:46
        line = fgetl(file);  %  пропуск первых 12 строк
    end
    for strout_i = 1:N  %  вставка средних координат в Борах
        x = mean(xyz(:, 3*strout_i-2))/const;
        y = mean(xyz(:, 3*strout_i-1))/const;
        z = mean(xyz(:, 3*strout_i))/const;
        atom_names{strout_i, 1} = ['a', num2str(strout_i)];
        fprintf(file2, '%3s%13.1f%17.10f%20.10f%20.10f\n', atom_names{strout_i, 1}, q(strout_i), [x, y, z]);
    end
    fgetl(file);
    fprintf(file2, '\n');
    fgetl(file);
    fprintf(file2, [' TOTAL NUMBER OF ATOMS               =   ', sprintf('%d', N), '\n']);  %  TOTAL NUMBER OF ATOMS
    for str_i = 49:52  %  копирование включая линию тире
        fprintf(file2, [fgetl(file), '\n']);
    end
    for str_i = 53:64
        line = fgetl(file);  %  пропуск вторых 12 строк
    end
    for strout_i = 1:N  %  вставка средних координат в ангстремах
        x = mean(xyz(:, 3*strout_i-2));
        y = mean(xyz(:, 3*strout_i-1));
        z = mean(xyz(:, 3*strout_i));
        fprintf(file2, '%3s%13.1f%15.10f%15.10f%15.10f\n', atom_names{strout_i, 1}, q(strout_i), [x, y, z]);
    end
    for str_i = 65:71  %  копирование до масс, не включая их
        fprintf(file2, [insertAfter(fgetl(file), "%", "%"), '\n']);
    end
    for str_i = 72:83
        line = fgetl(file);  %  пропуск третьих 12 строк
    end
    for strout_i = 1:N  %  вставка аббревиатур и масс
        m = q(strout_i);
        if (m == 8)
            m = 16;
        end
        k = length(atom_names{strout_i, 1});
        fprintf(file2, ['%5s%', num2str(k), 's%', num2str(25-k), '.5f\n'], '', atom_names{strout_i, 1}, m);
    end
    for str_i = 84:87  %  копирование до FREQUENCIES  IN CM**-1, включая пустую строку
        fprintf(file2, [fgetl(file), '\n']);
    end
    for str_i = 88:165
        fgetl(file);  %  пропуск блока svd донизу
    end
    SAYVETZ = repmat({''}, 10, 1);
    for str_i = 166:175
        SAYVETZ{str_i-165, 1} = fgetl(file);  %  копирование хвоста
    end
    fclose(file);

    REDUCED_MASS = '    REDUCED MASS:      0.00000     0.00000     0.00000     0.00000     0.00000';
    Step = 5;  %  максимальное число столбцов
    M = size(s, 1);
    for block = 1:Step:M
        fprintf(file2, '\n');  %  пустая строка

        Flag = (block+Step <= M);  %  если надо Step столбцов, то true, иначе false
        L = Flag*Step + (~Flag)*(M-block+1);  %  текущее число столбцов
        format_n = '';
        format_fr = '';
        format_ir = '';
        format_svd = '';
        for j = 1:L
            format_n = [format_n, '%12d'];  %#ok<AGROW>
            format_fr = [format_fr, '%10.2f  '];  %#ok<AGROW>
            format_ir = [format_ir, '%12.5f'];  %#ok<AGROW>
            format_svd = [format_svd, '%12.8f'];  %#ok<AGROW>
        end

        fprintf(file2, [sprintf(['%15s', format_n], '', block:block+L-1) '\n']);  %  номер блока
        freqs = zeros(1, L);
        for i = 1:L
            [freq, P1] = fourier_transform(U(:, block+i-1)', fs);
            freqs(1, i) = get_main_freq(freq, P1);
        end
        freqs = freqs/3E+10;  %  частота в обратных сантиметрах
        fprintf(file2, ['       FREQUENCY:   ', sprintf(format_fr, freqs), '\n']);  %  FREQUENCY
        fprintf(file2, [REDUCED_MASS(1:18+12*L), '\n']);
        fprintf(file2, ['    IR INTENSITY: ', sprintf(format_ir, s(block:block+L-1)), '\n']);
        fprintf(file2, '\n');

        for atom = 1:N
            for comp = 'X':'Z'
                if (comp == 'X')
                    k = length(atom_names{strout_i, 1});
                    fprintf(file2, ['%3d%3s%', num2str(k), 's%', num2str(13-k), 's'], atom, '', atom_names{atom, 1}, '');
                else
                    fprintf(file2, '%19s', '');
                end
                fprintf(file2, [sprintf(['%s', format_svd], comp, V(3*(atom-1)+(comp-'X')+1, block:block+L-1)) '\n']);
            end
        end
        if (M - block < Step)
            fprintf(file2, '\n\n\n');
        end
        for i = 0:1
            fprintf(file2, [SAYVETZ{5*i+1, 1}, '\n']);
            for j = 2:5
                fprintf(file2, [SAYVETZ{5*i+j, 1}(1:20+12*L), '\n']);
            end
        end
    end
    fclose(file2);
    fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файл для ChemCraft успешно записан по адресу:', output_file);
end