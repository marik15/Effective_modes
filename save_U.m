% Создает вспомогательный бинарный (.mat) файл для ускорения при последующих запусках

function save_U(filename, outputname)
    [~, qVxyz, ~] = get_n_qVxyz_xyz(filename);
    E12 = sqrt_energy(qVxyz);  %  считаем квадратный корень из матрицы
    [U, ~, ~] = svd(E12-mean(E12), 0);
    save(outputname, 'U');
end