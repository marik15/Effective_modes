clear all;
close all;
clc;

d_e1 = [-1; 0];
e1 = [sqrt(2); sqrt(2)]*0.5;

d_e2 = [1; 1];
e2 = [0; 1];

alpha = [1, 1];
omega = [3800, 3800];
phi = [0, 0, 0];
fs = 10000;
N = 10000;
t = 0:1/fs:(N-1)/fs;
x = [(d_e1 + alpha(1)*e1*cos(omega(1)*t))', (d_e2 + alpha(2)*e2*cos(omega(2)*t))'];

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
scatter(ax, x(:, 1), x(:, 2));
hold(ax, 'on');
axis(ax, 'equal');
scatter(ax, x(:, 3), x(:, 4));

[U, S, V] = svd(x-mean(x), 0);  %  PCA

q_e1 = quiver(ax, d_e1(1), d_e1(2), e1(1, 1), e1(2, 1), 'color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2);
q_e2 = quiver(ax, d_e2(1), d_e2(2), e2(1, 1), e2(2, 1), 'color', [0.4940, 0.1840, 0.5560], 'LineWidth', 2);
vec_id = 1;
q_v1 = quiver(ax, mean(x(:, 1)), mean(x(:, 2)), V(1, vec_id), V(2, vec_id), 'color', 'r', 'LineWidth', 2);
q_v2 = quiver(ax, mean(x(:, 3)), mean(x(:, 4)), V(3, vec_id), V(4, vec_id), 'color', 'b', 'LineWidth', 2);
legend([q_e1, q_e2, q_v1, q_v2], {'e_{1}', 'e_{2}', append('V_{1_1}, \lambda_{1} = ', num2str(S(1, 1))), append('V_{1_2}, \lambda_{1} = ', num2str(S(1, 1)))});