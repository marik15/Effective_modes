clearvars;
close all;
clc;

n = 3;  %  число атомов
fs = 10;
T = 10000;

xlimit = 10;  %  not used

arr_magnitude = zeros(3*n, 1);  %  растяжения векторов
arr_omega = zeros(3*n, 1);  %  частоты колебаний
qVxyz = zeros(T, 4*n);

for j = 1:n
    arr_magnitude(3*j-2:3*j) = randn(3, 1);%[randn; 0; 0];  %  randn(3, 1);
    arr_omega(3*j-2:3*j) = randn(3, 1);%repmat(rand, 3, 1);  %  randn(3, 1);
end

%arr_omega(2) = rand;

for t = 1:T
    for j = 1:4*n
        if (mod(j, 12) == 1)
            qVxyz(t, j) = 8;  %  заряд кислорода
        elseif (mod(j, 4) == 1)
            qVxyz(t, j) = 1;  %  водород
        else
            qVxyz(t, j) = arr_magnitude(3*floor((j-1)/4) + mod(j-1, 4))*cos(arr_omega(3*floor((j-1)/4) + mod(j-1, 4))*(t-1)/fs);
        end
    end
end

E12 = sqrt_energy(qVxyz);
T = E12;  %  .*E12;
[U, S, V] = svd(T-mean(T), 0);

j = 1;
k_arr = 1:size(U, 2);
[fig, fig2] = plot_wavelets_U(U, fs, xlimit, 0, diag(S), k_arr);