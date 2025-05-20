%  Возвращает k-ый столбец матрицы A, остальное заполняет нулями

function B = column_of_matrix(A, k)
    B = [zeros(size(A, 1), k - 1), A(:, k), zeros(size(A, 1), size(A, 2) - k)];
end