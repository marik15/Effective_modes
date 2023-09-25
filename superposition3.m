clearvars;
close all;
clc;

d_e1 = [0; 1];
e1 = [0; 0.25];

d_e2 = [sqrt(3); -1]*0.5;
e2 = [sqrt(3); -1]*0.125;

d_e3 = [-sqrt(3); -1]*0.5;
e3 = [-sqrt(3); -1]*0.125;

alpha = [1, 1, 1];
omega = [3800, 3800, 1600];
phi = [0, 0, 0];
fs = 10000;
N = 10000;
t = 0:1/fs:(N-1)/fs;
x = [(d_e1 + alpha(1)*e1*cos(omega(1)*t))', (d_e2 + alpha(2)*e2*cos(omega(2)*t))', (d_e3 + alpha(3)*e3*cos(omega(3)*t))'];

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
s1 = plot(ax, x(:, 1), x(:, 2), 'LineWidth', 2);
hold(ax, 'on');
axis(ax, 'equal');
s2 = plot(ax, x(:, 3), x(:, 4), 'LineWidth', 2);
s3 = plot(ax, x(:, 5), x(:, 6), 'LineWidth', 2);

%  legend([s1, s2, s3], {'q_1', 'q_2', 'q_3'});

[U, S, V] = svd(x-mean(x), 0);  %  PCA

q_e1 = quiver(ax, d_e1(1), d_e1(2), e1(1, 1), e1(2, 1), 'color', [0.8500, 0.3250, 0.0980], 'LineWidth', 4);
q_e2 = quiver(ax, d_e2(1), d_e2(2), e2(1, 1), e2(2, 1), 'color', [0.4940, 0.1840, 0.5560], 'LineWidth', 4);
q_e3 = quiver(ax, d_e3(1), d_e3(2), e3(1, 1), e3(2, 1), 'color', [0.5, 0.5, 0.5], 'LineWidth', 4);
%  legend([s1, s2, s3, q_e1, q_e2, q_e3], {'q_1', 'q_2', 'q_3', 'e_{1}', 'e_{2}', 'e_{3}'});
q_v1 = quiver(ax, mean(x(:, 1)), mean(x(:, 2)), V(1, 1), V(2, 1), 'color', 'r', 'LineWidth', 4);
q_v2 = quiver(ax, mean(x(:, 3)), mean(x(:, 4)), V(3, 1), V(4, 1), 'color', 'g', 'LineWidth', 4);
q_v3 = quiver(ax, mean(x(:, 5)), mean(x(:, 6)), V(5, 2), V(6, 2), 'color', 'b', 'LineWidth', 4);
legend([s1, s2, s3, q_e1, q_e2, q_e3, q_v1, q_v2, q_v3], {'q_1', 'q_2', 'q_3', 'e_{1}', 'e_{2}', 'e_{3}', 'V_{1, 1}', 'V_{1, 2}', 'V_{2, 3}'});