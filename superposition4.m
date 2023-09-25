clearvars;
close all;
clc;

d_e1 = [0; 1];
e1 = [0; 0.25];

d_e2 = [sqrt(3); -1]*0.5;
e2 = [sqrt(3); -1]*0.125;

d_e3 = [-sqrt(3); -1]*0.5;
e3 = [-sqrt(3); -1]*0.125;

omega = [750, 1075, 1075];
phi = [0, 0, 0];
fs = 10000;
N = 10000;
t = 0:1/fs:(N-1)/fs;
%x = [1/sqrt(3)*(d_e1 + e1*cos(omega(1)*t) + d_e2 + e2*cos(omega(1)*t) + d_e3 + e3*cos(omega(1)*t))', 1/sqrt(6)*(d_e1 + 2*e1*cos(omega(1)*t) + d_e2 - e2*cos(omega(2)*t) + d_e3 - e3*cos(omega(3)*t))', 1/sqrt(2)*(d_e2 + e2*cos(omega(2)*t) + d_e3 - e3*cos(omega(3)*t))'];
Q_1 = [1/sqrt(3)*(d_e1 + e1*cos(omega(1)*t))', 1/sqrt(3)*(d_e2 + e2*cos(omega(1)*t))', 1/sqrt(3)*(d_e3 + e3*cos(omega(1)*t))'];
Q_2 = [1/sqrt(6)*(d_e1 + 2*e1*cos(omega(2)*t))', 1/sqrt(6)*(d_e2 - e2*cos(omega(2)*t))', 1/sqrt(6)*(d_e3 - e3*cos(omega(2)*t))'];
Q_3 = [1/sqrt(2)*(d_e1').*ones(length(t), 2), 1/sqrt(2)*(d_e2 + e2*cos(omega(3)*t))', 1/sqrt(2)*(d_e3 - e3*cos(omega(3)*t))'];
x = 1*Q_1 + 1*Q_2 + 1*Q_3;

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
s1 = plot(ax, x(:, 1), x(:, 2), 'LineWidth', 2);
hold(ax, 'on');
axis(ax, 'equal');
s2 = plot(ax, x(:, 3), x(:, 4), 'LineWidth', 2);
s3 = plot(ax, x(:, 5), x(:, 6), 'LineWidth', 2);

%  legend([s1, s2, s3], {'q_1', 'q_2', 'q_3'});

[U, S, V] = svd(x-mean(x), 0);  %  PCA

q_v1 = quiver(ax, mean(x(:, 1)), mean(x(:, 2)), V(1, 2), V(2, 2), 'color', 'r', 'LineWidth', 4);
q_v2 = quiver(ax, mean(x(:, 3)), mean(x(:, 4)), V(3, 2), V(4, 2), 'color', 'g', 'LineWidth', 4);
q_v3 = quiver(ax, mean(x(:, 5)), mean(x(:, 6)), V(5, 2), V(6, 2), 'color', 'b', 'LineWidth', 4);
legend([s1, s2, s3, q_v1, q_v2, q_v3], {'q_1', 'q_2', 'q_3', 'V_{2, 1}', 'V_{2, 2}', 'V_{2, 3}'});