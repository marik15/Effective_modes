function write_overlap_matrix(A, L, diff, step, path, name)
    N = size(A, 2)/3;
    for t = 1:size(A, 1)
        image = reshape(A(t, :, :), 3*N, 3*N);
        matrix_filename = append(path, name, ' Интервал [', num2str((t-1)*step+1), '; ', num2str((t-1)*step+L), '] и [', num2str((t-1)*step+1+diff), '; ', num2str((t-1)*step+1+diff+L), '].txt');
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