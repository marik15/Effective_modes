%  Лосс-функция

function y = tmp_fun(x, U)
    y = norm(U(:, 5) - x(1)*U(:, 1) - x(2)*U(:, 3));
end