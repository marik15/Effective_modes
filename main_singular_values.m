% ¬ычисл€ет и строит график сингул€рных чисел от пор€дкового номера

path_data = 'D:\MATLAB\Ёффективные моды\data\';  %  папка с файлами, в конце символ \
files = {'extract.irc'};  %  имена файлов
t_step = 5000;  %  шаг, отсчеты
t1 = 1;  %  начало траектории
t2 = 'end';  % конец траектории: целое число, либо слово 'end', если нужно посчитать до конца файла, а число строк неизвестно

% --- ниже не нужно редактировать

output_path = [path_data, '—ингул€рные числа\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
        
for k = 1:numel(files)
    filename = [path_data, files{k}];
    [n, qVxyz_full, ~, ~] = load_n_qVxyz_xyz_fs(path_data, filename);  %  считываем данные из .irc

    if (strcmp(t2, 'end'))
        t2 = size(qVxyz_full, 1);
    end

    for t = 0:fix((t2-t1+1)/t_step)-1  %  цикл по временным участкам
        t1_cur = t1 + t*t_step;
        t2_cur = t1_cur + t_step - 1;
        
        qVxyz = qVxyz_full(t1_cur:t2_cur, :);
        E12 = energy_power(qVxyz, 0.5);
        s = svd(E12-mean(E12));  %  сингул€рные числа в пор€дке убывани€

        s = s.^2 * sqrt((1e+4) / size(U, 1) / 4.1868);  %  энерги€, ккал/моль
        plot(ax, s);  %  построение графика
        xlim(ax, [1, 3*n]);
        title(ax, ['«ависимость квадратов сингул€рных чисел от их номера дл€ файла ', files{k}, ' Time ', num2str(t1_cur), '-', num2str(t2_cur)], 'FontSize', 16, 'Interpreter', 'none');
        xlabel(ax, 'Ќомер числа', 'FontSize', 14);
        ylabel(ax, ' вадрат сингул€рного числа, пересчитанный в ккал/моль', 'FontSize', 14);
        %saveas(fig, [output_path, '√рафик SVD дл€ ', files{k}, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.jpg']);
        %writematrix(s, [output_path, '„исла SVD дл€ ', files{k}, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.txt'], 'Delimiter', 'space');  %  запись сингул€рных значений в текстовый файл
    end
end

close(fig);

fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), '‘айлы с сингул€рными числами успешно записаны по адресу:', output_path);