%  Записывает данные в форматированный файл

function write_matrix(filename, data, format, permission)
    file = fopen(filename, permission);
    for line = 1:size(data, 1)
        fprintf(file, format, data(line, :));
        if (line ~= size(data, 1))
            fprintf(file, '\n');
        end
    end
    fclose(file);
end