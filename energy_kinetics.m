%  Решает уравнение с данными k, возвращает невязку с графиком

function res = energy_kinetics(k, arr, t, const)
    y0 = arr(1, :);  %  начальные условия
    [tspan, sol] = ode15s(@(t, y) odefun_kin(t, y, k), linspace(t(1), t(end), const), y0);  %  решить уравнение
    y = interp1(tspan, sol, t);
    res = norm(y - arr);
end