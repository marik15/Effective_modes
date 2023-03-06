% Записывает в файл интеграл перекрываний нормальных и эффективных мод между собой

function write_overlap_matrix(A, start_arr, end_arr, path, name)
    n = size(A, 2)/3;
    for t = 1:size(A, 1)
        image = reshape(A(t, :, :), 3*n, 3*n);
        matrix_filename = append(path, name, ' интервал (отсчеты) [', num2str(start_arr(t)), '; ', num2str(end_arr(t)), '].txt');
        file = fopen(matrix_filename, 'w');
        for h = 1:3*n
            for w = 1:3*n
                fprintf(file, '%.10E ', image(h, w));
            end
            fprintf(file, '\n');
        end
        fclose(file);
    end
    fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Матрицы сохранены по адресу:', path);
end