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
for k1 = 0:0.005:0.005
    for k2 = 0:0.005:0.005
        for k3 = 0.001:0.0005:0.005
            %for k4 = 0:0.1:1
                %for k5 = 0:0.1:1
                    %for k6 = 0:0.1:1  %  из графиков понять порядок
                        k4 = k1;
                        k5 = k2;
                        k6 = k3;
                        cellfun(@clear, syms);
                        syms a(t) b(t) r(t);
                        ode1 = diff(a, t) == k4 * b + k3 * r - (k1 + k6) * a;  %  0.3 s
                        ode2 = diff(b, t) == k1 * a + k5 * r - (k2 + k4) * b;
                        ode3 = diff(r, t) == k6 * a + k2 * b - (k3 + k5) * r;
                        odes = [ode1, ode2, ode3];
                        cond1 = a(1) == y0(1);
                        cond2 = b(1) == y0(2);
                        cond3 = r(1) == y0(3);
                        conds = [cond1, cond2, cond3];
                        [aSol(t), bSol(t), rSol(t)] = dsolve(odes, conds);
                        er_syms = norm([double(rSol(x_arr)') - arr(x_arr, 1); double(aSol(x_arr)') - arr(x_arr, 2); double(bSol(x_arr)') - arr(x_arr, 3)]);
                        if (er_syms < min_er_syms)
                            min_er_syms = er_syms;
                            best_k_syms = [k1, k2, k3, k4, k5, k6];
                            best_Sol_syms = [double(aSol(x_arr)); double(bSol(x_arr)); double(rSol(x_arr))];
                        end
                        cellfun(@clear, syms);
                    %end
                %end
            %end
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

p1 = plot(ax, x, best_Sol_syms(1, :), 'Color', colors{2});
p2 = plot(ax, x, best_Sol_syms(2, :), 'Color', colors{3});
p3 = plot(ax, x, best_Sol_syms(3, :), 'Color', colors{1});

p4 = plot(ax, x, arr(:, 1), 'Color', colors{1}, 'LineWidth', 2);
p5 = plot(ax, x, arr(:, 2), 'Color', colors{2}, 'LineWidth', 2);
p6 = plot(ax, x, arr(:, 3), 'Color', colors{3}, 'LineWidth', 2);

xlim(ax, [0, x_arr(end)]*step_divided_to_fs*(1e+12));
xlabel(ax, 'Время, пс');
ylabel(ax, 'Энергия, ккал/моль');
title(ax, files_group{file_id}, 'Interpreter', 'none');

lgd = legend(ax, [p4, p5, p6, p3, p1, p2], {'PCA Radial', 'PCA Angular', 'PCA Bending', 'Diff.eq. Radial', 'Diff.eq. Angular', 'Diff.eq. Benging'});
set(ax, 'FontSize', 24);
Str = {append('k1 = ', string(best_k_syms(1)/(step_divided_to_fs*(1e+12))));
       append('k2 = ', string(best_k_syms(2)/(step_divided_to_fs*(1e+12))));
       append('k3 = ', string(best_k_syms(3)/(step_divided_to_fs*(1e+12))));
       append('k4 = ', string(best_k_syms(4)/(step_divided_to_fs*(1e+12))));
       append('k5 = ', string(best_k_syms(5)/(step_divided_to_fs*(1e+12))));
       append('k6 = ', string(best_k_syms(6)/(step_divided_to_fs*(1e+12))));};
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