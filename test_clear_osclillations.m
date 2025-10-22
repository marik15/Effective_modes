clearvars;
close all;
clc;

fs = 2e+15;  %  частота дискретизации, Гц
T = 1000;  %  число отсчетов
q = [1, 1, 8, 1, 1, 8, 1, 1, 8]';  %  заряды

n = size(q, 1);
A = (1e-15) * [1, 0.5, zeros(1, 3 * n - 2)];  %  randn(1, 3 * n);  %  [1, zeros(1, 3 * n - 1)];  %  амплитуды, метры
f = (3e+10) * [4000, 1800, zeros(1, 3 * n - 2)];  %  4000 * (3e+10) * rand(1, 3 * n);  zeros(1, 3 * n - 1)  %  частоты колебаний, Гц
phi = 2 * pi * 0 * rand(1, 3 * n);  %  фазы колебаний, радиан

V_1 = ones(3 * n, 3 * n);%randn(3 * n, 3 * n);
for mode = 1:(3*n)
    V_1(:, mode) = V_1(:, mode)/norm(V_1(:, mode));  %  нормировка
end

xyz = zeros(T, 3 * n);
for t = 1:T
    time = (t - 1)/fs;
    for mode = 1:(3 * n)
        xyz(t, :) = A .* sin(2 * pi * f * time + phi) .* V_1(:, mode)';  %  мода вдоль столбца
    end
end

qVxyz = zeros(T, 4 * n);
for t = 1:T
    time = (t - 1)/fs;
    tmp = 2 * pi * f .* A .* cos(2 * pi * f * time + phi) .* V_1(:, mode)';
    for k = 1:n
        qVxyz(t, (4 * k - 3):(4 * k)) = [q(k), tmp((3 * k - 2):(3 * k))];
    end
end

E12 = energy_power(qVxyz, 0.5);
[U, S, V] = svd(E12 - mean(E12), 0);

S(1, 1)/S(2, 2)
(A(1) * f(1) / (A(2) * f(2)))

%write_wx_for_visualizer(append(cd, '\wx.sample'), q, xyz, n, U, diag(S), V, fs, append('Clear oscillation ', string(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss')), '.txt'));