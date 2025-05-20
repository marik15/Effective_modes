%  Аппроксимирует данные и возвращает коэффициенты экспоненциальной зависимости

function [A, k] = determine_exp_coefficients(x, y)
    c = fit(x, y, 'exp1');
    A = c.a;
    k = c.b;
end