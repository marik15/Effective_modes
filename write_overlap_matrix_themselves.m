% Записывает в файл интеграл перекрываний эффективных мод между собой

function write_overlap_matrix_themselves(A, start_arr, end_arr, path, name)
    N = size(A, 2)/3;
    for t = 1:size(A, 1)
        image = reshape(A(t, :, :), 3*N, 3*N);
        matrix_filename = append(path, name, ' интервалы (отсчеты) [', num2str(start_arr(t)), '; ', num2str(end_arr(t)), '] и [', num2str(start_arr(t+1)), '; ', num2str(end_arr(t+1)), '].txt');
        file = fopen(matrix_filename, 'w');
        for h = 1:3*N
            for w = 1:3*N
                fprintf(file, '%.10E ', image(h, w));
            end
            fprintf(file, '\n');
        end
        fclose(file);
    end
    fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Матрицы сохранены по адресу:', path);
end