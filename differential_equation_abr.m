clear all;
close all;
clc;

y0 = [3.6855, 0.9423, 0.6990];  %  y = [a, b, r]

files_group = {'w5_2a.mat', 'w5_2a_1.mat', 'w5_2a_2.mat'};
file_id = 1;
[arr, step_divided_to_fs] = get_arr('E:\MATLAB\Эффективные моды\Вспомогательные файлы\', files_group, file_id);
x_arr = 1:size(arr, 1);

min_er_syms = Inf;
min_er_ode = Inf;

tic;
for k1 = 0:0.1:1
    for k2 = 0:0.1:1
        for k3 = 0:0.1:1
            for k4 = 0:0.1:1
                for k5 = 0:0.1:1
                    for k6 = 0:0.1:1  %  из графиков понять порядок
                        [t_ode, y_ode] = ode45(@(t, y) odefun(y, [k1, k2, k3, k4, k5, k6]), [1, x_arr(end)], y0);  %  0.0002 s
                        y_arr = interp1(t_ode, y_ode, x_arr);
                        er_ode = norm([y_arr(:, 3) - arr(x_arr, 1); y_arr(:, 1) - arr(x_arr, 2); y_arr(:, 2) - arr(x_arr, 3)]);
                        if (er_ode < min_er_ode)
                            min_er_ode = er_ode;
                            best_k_ode = [k1, k2, k3, k4, k5, k6];
                            best_Sol_ode = y_arr;
                        end
                    end
                end
            end
        end
    end
end
toc;

markers = {'square', 'o', '^'};
colors = {'#0072BD', '#D95319', '#EDB120'};

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
hold(ax, 'on');
box(ax, 'on');
grid(ax, 'on');

x = x_arr*step_divided_to_fs*(1e+12);

p1 = plot(ax, x, best_Sol_ode(:, 1), 'Color', colors{2});
p2 = plot(ax, x, best_Sol_ode(:, 2), 'Color', colors{3});
p3 = plot(ax, x, best_Sol_ode(:, 3), 'Color', colors{1});

p4 = plot(ax, x, arr(:, 1), 'Color', colors{1}, 'LineWidth', 2);
p5 = plot(ax, x, arr(:, 2), 'Color', colors{2}, 'LineWidth', 2);
p6 = plot(ax, x, arr(:, 3), 'Color', colors{3}, 'LineWidth', 2);

xlim(ax, [0, x_arr(end)]*step_divided_to_fs*(1e+12));
xlabel(ax, 'Время, пс');
ylabel(ax, 'Энергия, ккал/моль');
title(ax, files_group{file_id}, 'Interpreter', 'none');

lgd = legend(ax, [p4, p5, p6, p3, p1, p2], {'PCA Radial', 'PCA Angular', 'PCA Bending', 'Diff.eq. Radial', 'Diff.eq. Angular', 'Diff.eq. Benging'});
set(ax, 'FontSize', 24);
Str = {append('k1 = ', string(best_k_ode(1)));
       append('k2 = ', string(best_k_ode(2)));
       append('k3 = ', string(best_k_ode(3)));
       append('k4 = ', string(best_k_ode(4)));
       append('k5 = ', string(best_k_ode(5)));
       append('k6 = ', string(best_k_ode(6)));};
an = annotation(fig, 'textbox', [0.72, 0.82, 0.1, 0.1], 'String', Str, 'FontSize', 24);

%{
fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
hold(ax, 'on');
plot(ax, x_arr, best_Sol_syms(1, :), 'Color', colors{2});
plot(ax, x_arr, best_Sol_syms(2, :), 'Color', colors{3});
plot(ax, x_arr, best_Sol_syms(3, :), 'Color', colors{1});

plot(ax, x_arr, arr(:, 1), 'Color', colors{1}, 'LineWidth', 2);
plot(ax, x_arr, arr(:, 2), 'Color', colors{2}, 'LineWidth', 2);
plot(ax, x_arr, arr(:, 3), 'Color', colors{3}, 'LineWidth', 2);
%}