% ¬ычисл€ет и строит график сингул€рных чисел от пор€дкового номера

clearvars;  %  удалить все переменные
close all;  %  закрыть все графики
clc;  %  очистить вывод

path_data = 'D:\MATLAB\Ёффективные моды\data\';  %  папка с файлами, в конце символ \
files = {'w3_1a.irc';
         'w3_2a.irc';
         'w3_3a.irc'
         'w3_3a_1.irc';
         'w3_3a_2.irc';
         'w3_4a.irc'};  %  имена файлов

t_step = 100000;  %  шаг, отсчеты
t1 = 1;  %  начало траектории
t2 = 'end';  % конец траектории: целое число, либо слово 'end', если нужно посчитать до конца файла, а число строк неизвестно

% --- ниже не нужно редактировать

k_kkal_mole = 627.5095;  %  коэффициент перевода а.е.м. * (бор/фс)^2 в ккал/моль: E = 0.5 * k * m * V^2;

output_path = [path_data, '—ингул€рные числа\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');
box(ax, 'on');

for k = 1:numel(files)
    filename = [path_data, files{k}];
    [n, qVxyz_full, ~, ~] = load_n_qVxyz_xyz_fs(path_data, filename);  %  считываем данные из .irc

    if (strcmp(t2, 'end'))
        t2 = size(qVxyz_full, 1);
    end
    cla(ax);

    for t = 0:fix((t2-t1+1)/t_step) - 1  %  цикл по временным участкам
        t1_cur = t1 + t * t_step;
        t2_cur = t1_cur + t_step - 1;

        qVxyz = qVxyz_full(t1_cur:t2_cur, :);
        E12 = energy_power(qVxyz, 0.5);
        s = svd(E12 - mean(E12), 0);  %  сингул€рные числа в пор€дке невозрастани€

        s = s.^2 / size(E12, 1) * k_kkal_mole;  %  энерги€, ккал/моль
        N_eff = count_N_eff(s);
        plot(ax, s, 'LineWidth', 2, 'Marker', 'square');  %  построение графика
        line(ax, [N_eff, N_eff], [0, s(1)], 'LineWidth', 2);
        text(ax, N_eff, s(1), sprintf('N_{eff} = %.2f', N_eff), 'FontSize', 40, 'BackgroundColor', 'none', 'EdgeColor', 'none', 'Margin', 8, 'VerticalAlignment', 'middle');
        xlim(ax, [1, 3 * n]);
        fname = strrep(files{k}, '_', '\_');
        title(ax, ['$\sigma_{k}^2$ for ', fname, ' time frames: ', num2str(t1_cur), '-', num2str(t2_cur)], 'Interpreter', 'latex');
        xlabel(ax, 'k');
        ylabel(ax, '\sigma_k^2, ккал/моль', 'Interpreter', 'tex');
        set(ax, 'FontSize', 40);
        saveas(fig, [output_path, '√рафик SVD дл€ ', files{k}, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.png']);
        writematrix(s, [output_path, '„исла SVD дл€ ', files{k}, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.txt'], 'Delimiter', 'space');  %  запись сингул€рных значений в текстовый файл
    end
end

close(fig);

fprintf('\t%s\n\t%s\n\t%s\n', string(datetime('now')), '‘айлы с сингул€рными числами записаны по адресу:', output_path);