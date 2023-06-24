% Фильтрует спектр

filename = 'C:\MATLAB\Эффективные моды\w5_all_05.irc';  %  файл

fs = 1E+16;  %  частота дискретизации, Гц
xlimit = 4000;  %  верхняя граница частоты, см^-1

% ---

[filepath, name, ~] = fileparts(filename);
[~, qVxyz, ~] = get_n_qVxyz_xyz(filename);
E12 = sqrt_energy(qVxyz);
T = E12.*E12;
[U, ~, ~] = svd(T, 0);
[fig, fig2] = plot_fft_U(U, fs, xlimit);
print(fig, append(name, ' spectrum'), '-painters', '-dpng', '-r300');
print(fig2, append(name, ' spectrum'), '-painters', '-dpng', '-r300');
close([fig, fig2]);