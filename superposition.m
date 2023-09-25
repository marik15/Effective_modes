e1 = [1; 0];
e2 = [-sqrt(3); -1]*0.5;
e3 = [sqrt(3); -1]*0.5;
%{
e1 = [sqrt(3); -1]*0.5;
e2 = [-sqrt(3); -1]*0.5;
e3 = [1; 0];
%}
alpha = [1, 1, 1];
omega = [3800, 3800, 1600];
phi = [0, 0, 0];
fs = 10000;
N = 10000;
t = 0:1/fs:(N-1)/fs;
x = alpha(1)/sqrt(3)*(e1+e2+e3)*cos(omega(1)*t + phi(1)) + alpha(2)/sqrt(6)*(2*e1-e2-e3)*cos(omega(2)*t + phi(2)) + alpha(3)/sqrt(2)*(e2-e3)*cos(omega(3)*t + phi(3));
%x = alpha(1)*e1*cos(omega(1)*t + phi(1)) + alpha(2)*e2*cos(omega(2)*t + phi(2)) + alpha(3)*e3*cos(omega(3)*t + phi(3));
x = x';

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
plot(ax, x(:, 1), x(:, 2));
hold(ax, 'on');
axis(ax, 'equal');

%{
p = scatter(ax, x(1, 1), x(1, 2), 'b');

for t_cur = t(1):1:t(end)
    x = alpha(1)*e1*cos(omega(1)*t_cur + phi(1)) + alpha(2)*e2*cos(omega(2)*t_cur + phi(2));
    set(p, 'XData', x(1), 'YData', x(2));
    drawnow;
end
%}

%  PCA
[U, S, V] = svd(x-mean(x), 0);

q_e1 = quiver(ax, 0, 0, e1(1, 1), e1(2, 1), 'color', 'k', 'LineWidth', 2);
q_e2 = quiver(ax, 0, 0, e2(1, 1), e2(2, 1), 'color', 'k', 'LineWidth', 2);
q_e3 = quiver(ax, 0, 0, e3(1, 1), e3(2, 1), 'color', 'k', 'LineWidth', 2);
q_v1 = quiver(ax, 0, 0, V(1, 1), V(2, 1), 'color', 'r', 'LineWidth', 2);
q_v2 = quiver(ax, 0, 0, V(1, 2), V(2, 2), 'color', 'b', 'LineWidth', 2);
legend([q_e1, q_e2, q_e3, q_v1, q_v2], {'e_{1}', 'e_{2}', 'e_{3}', append('V_{1}, \lambda_{1} = ', num2str(S(1, 1))), append('V_{2}, \lambda_{2} = ', num2str(S(2, 2)))});

%  t-SNE
%{
fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax2 = axes(fig2);
Y = tsne(x);
scatter(ax2, Y(:, 1), Y(:, 2));
%}