clearvars;
close all;
clc;

global y0 h k

y0 = [0.01; -0.05; 0.01];
v0 = [0; 0; 0];

omega = [3800, 3900, 1650];
k = omega.^2;
chi = [43, 166, 16;
       166, 48, 20;
       16, 20, 17];
h = zeros(3, 3);
for i = 1:3
    for j = 1:3
        if (i ~= j)
            h(i, j) = chi(i, j)*omega(i)*omega(j);
        else
            h(i, i) = 2/3*chi(i, i)*(omega(i)^2);
        end
    end
end
h = h;  %  edit

t = [0; 1];

[t_span, y] = ode45(@(t, y) odefun1(t, y), t, [y0; v0]);

%id = 1;
%plot(y(:, id), y(:, id+3));
%plot(t_span, y(:, id));

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax1 = subplot(3, 3, [1, 2], axes(fig));
plot(ax1, t_span, y(:, 1));
ax2 = subplot(3, 3, [4, 5], axes(fig));
plot(ax2, t_span, y(:, 2));
ax3 = subplot(3, 3, [7, 8], axes(fig));
plot(ax3, t_span, y(:, 3));
ylim(ax1, [min(y(:, 1)), max(y(:, 1))]);
ylim(ax2, [min(y(:, 2)), max(y(:, 2))]);
ylim(ax3, [min(y(:, 3)), max(y(:, 3))]);

ax_11 = subplot(3, 3, 3, axes(fig));
[pxx_1, f_1] = plomb(y(:, 1), t_span);
plot(ax_11, f_1, pxx_1);
[~, indx_1] = max(pxx_1);
title(ax_11, ['max peak = ', num2str(f_1(indx_1))]);
ax_12 = subplot(3, 3, 6, axes(fig));
[pxx_2, f_2] = plomb(y(:, 2), t_span);
plot(ax_12, f_2, pxx_2);
[~, indx_2] = max(pxx_2);
title(ax_12, ['max peak = ', num2str(f_2(indx_2))]);
ax_13 = subplot(3, 3, 9, axes(fig));
[pxx_3, f_3] = plomb(y(:, 3), t_span);
plot(ax_13, f_3, pxx_3);
[~, indx_3] = max(pxx_3);
title(ax_13, ['max peak = ', num2str(f_3(indx_3))]);
xlim([ax_11, ax_12, ax_13], [0, 2000]);