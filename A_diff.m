%  Вычисляет любую производную от заданной функции

function val = A_diff(diff_ord, t, x, n, j)
    val = zeros(1, n);
    syms alpha0 gamma0 c t0
    y(t0) = (alpha0 * exp(-gamma0*t0) + c)^(0.5);
    for k = 1:n
        alpha_val = x(3*n*(j-1) + 3*k-2);
        gamma_val = x(3*n*(j-1) + 3*k-1);
        c_val = x(3*n*(j-1) + 3*k);
        val(k) = double (subs(diff(y(t0), diff_ord, t0), [alpha0, gamma0, c, t0], [alpha_val, gamma_val, c_val, t]));
    end
end