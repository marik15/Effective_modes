%  Решает систему нелинейных уравнений кинетики

clearvars;
close all;
clc;

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
files_group = {'w5_2a.mat', 'w5_2a_1.mat', 'w5_2a_2.mat'};
file_id = 1;  %  какой файл
step = 500;  %  по сколько отсчетов шагаем

[arr, fs] = get_arr(path_aux, files_group, file_id, step);
E_kin_rab = get_initial_data('D:\MATLAB\Эффективные моды\initial_data.xlsx', files_group{file_id}(1:end-4));
n = size(arr, 2);
N = [2*n, max(n - 6 - 3*n, 3), n];  %  r, a, b

x0 = abs(randn(1, 5*sum(N) + 6));
omega_examples = [0.1:0.1:1, 1.2:0.2:2, 2.25:0.25:3];
x_typical = [omega_examples(randperm(numel(omega_examples), N(1))).*(1+0.1*randn(1, N(1))), ...
             omega_examples(randperm(numel(omega_examples), N(2))).*(1+0.1*randn(1, N(2))), ...
             omega_examples(randperm(numel(omega_examples), N(3))).*(1+0.1*randn(1, N(3))), ...
             zeros(1, (E_kin_rab(1) ~= 0) * N(1)), 2*pi*rand(1, (E_kin_rab(1) == 0) * N(1)), ...
             zeros(1, (E_kin_rab(2) ~= 0) * N(2)), 2*pi*rand(1, (E_kin_rab(2) == 0) * N(2)), ...
             zeros(1, (E_kin_rab(3) ~= 0) * N(3)), 2*pi*rand(1, (E_kin_rab(3) == 0) * N(3)), ...
             ones(1, 6).*(1+0.1*randn(1, 6)), ...
             (1+0.1*randn(1, E_kin_rab(1) ~= 0) * N(1)), zeros(1, (E_kin_rab(1) == 0) * N(1)), ...
             (1+0.1*randn(1, E_kin_rab(2) ~= 0) * N(2)), zeros(1, (E_kin_rab(2) == 0) * N(2)), ...
             (1+0.1*randn(1, E_kin_rab(3) ~= 0) * N(3)), zeros(1, (E_kin_rab(3) == 0) * N(3))];

%x0 = [repmat(1.5          , 1, 3).*(1+0.1*randn(1, sum(n))), 2*pi*rand(1, sum(n)), ones(1, 6).*(1+0.1*randn(1, 6)), ones(1, 3*sum(n)).*(1+0.1*randn(1, 3*sum(n)))];  %  n==[1,1,1]
%x0 = x;

%w = [1; 1; 1; ones(3*size(arr, 1)-3, 1); zeros(size(arr, 1)-1, 1)];

A = zeros(sum(N), numel(x0));
for row = 1:sum(N)
    A(row, :) = [zeros(1, 2*sum(N) + 6 + 3 * (row - 1)), 1, 0, 1, zeros(1, 3*sum(N) - 3 * row)];
end
b = zeros(sum(N), 1);
Aeq = zeros(sum(N), size(x0, 2));
for idx = 1:numel(E_kin_rab)
    if (E_kin_rab(idx) ~= 0)  %  интервал активный
        for row = 1:N(idx)
            Aeq(sum(N(1:(idx-1))) + row, :) = [zeros(1, sum(N) + sum(N(1:(idx-1))) + (row - 1)), 1, zeros(1, 4*sum(N) + 6 - sum(N(1:(idx-1))) - row)];
        end
    else  %  интервал неактивный
        for row = 1:N(idx)
            Aeq(sum(N(1:(idx-1))) + row, :) = [zeros(1, 2*sum(N) + 6 + sum(N(1:(idx-1))) + 3 * (row - 1)), 1, 0, 1, zeros(1, 3*sum(N) - sum(N(1:(idx-1))) - 3 * row)];
        end
    end
end
beq = zeros(size(Aeq, 1), 1);
lb = [zeros(1, 2*sum(N) + 6), repmat([-5, 0, 0], 1, sum(N))];
ub = [2*pi*0.6*ones(1, sum(N)), 2*pi*ones(1, sum(N)), 5*ones(1, 6), repmat([10, 5, 10], 1, sum(N))];
options = optimoptions('fmincon', 'Display', 'iter', 'MaxIterations', 1e+3, 'MaxFunctionEvaluations', 3e+4);  %  'TypicalX', x_typical, 'OptimalityTolerance', 1e-8
[x, fval] = fmincon(@(vec) norm(nonlinear_equations_system_full_4(vec, N, size(arr, 1), E_kin_rab))^2, x0, -A, b, Aeq, beq, lb, ub, [], options);

t = (0:(size(arr, 1) - 1)) * step / (fs * (1e-12));
fig = plot_solution(t, arr, x, N);