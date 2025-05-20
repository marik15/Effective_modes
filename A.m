%  Возвращает значения функции A, j = {1, 2, 3}

function y = A(t, x, N, j)
    y = zeros(1, N(j));
    prestart_index = 2*sum(N) + 6 + 3*sum(N(1:(j-1)));
    for k = 1:N(j)
        alpha = x(prestart_index + 3*k-2);
        gamma = x(prestart_index + 3*k-1);
        c =     x(prestart_index + 3*k);
        y(k) = (alpha * exp(-gamma*t) + c)^(0.5);
    end
end