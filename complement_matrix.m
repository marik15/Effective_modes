%  Возвращает k первых столбцов матрицы A, остальное заполняет нулями

function B = complement_matrix(A, k)
    B = [A(:, 1:k), zeros(size(A, 1), size(A, 2) - k)];
end