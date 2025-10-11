%  Решает уравнение с данными k, возвращает сумму квадратов невязки с графиком

function res = energy_kinetics(x, arr, t, const)
    %[tspan, sol] = ode15s(@(t, y) odefun_kin(t, y, k), linspace(t(1), t(end), const), arr(1, :));  %  решить уравнение
    y0 = x(7:9);  %  начальные условия
    [tspan, sol] = ode15s(@(t, y) odefun_kin(t, y, x(1:6)), linspace(t(1), t(end), const), y0);  %  решить уравнение
    y = interp1(tspan, sol, t);
    res = norm(y - arr, 'fro');
end