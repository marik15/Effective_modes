% ¬ычисл€ет и строит график сингул€рных чисел от пор€дкового номера

path_data = 'C:\MATLAB\Ёффективные моды\';  %  папка с файлами, в конце символ \
files = {'w5_1a.irc'};  %  имена файлов
t_step = 20000;  %  шаг, отсчеты
t1 = 1;  %  начало траектории
t2 = 100000;  % конец траектории: целое число, либо слово 'end', если нужно посчитать до конца файла, а число строк неизвестно

% --- ниже не нужно редактировать

output_path = [path_data, '—ингул€рные числа\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

for k = 1:numel(files)
    filename = [path_data, files{k}];

    for t = 0:fix((t2-t1+1)/t_step)-1  %  цикл по временным участкам
        t1_cur = t1 + t*t_step;
        t2_cur = t1_cur + t_step - 1;
        [n, qVxyz_full, ~] = load_n_qVxyz_xyz(path_data, filename);  %  считываем данные из .irc
        qVxyz = qVxyz_full(t1_cur:t2_cur, :);
        E12 = sqrt_energy(qVxyz);
        s = svd(E12-mean(E12));  %  сингул€рные числа в пор€дке убывани€

        if (strcmp(t2, 'end'))
            t2 = size(E12, 1);
        end

        fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
        ax = axes(fig);
        plot(ax, s);  %  построение графика
        xlim(ax, [1, 3*n]);
        title(ax, ['¬еличина сингул€рных чисел от их номера дл€ файла ', files{k}], 'FontSize', 16, 'Interpreter', 'none');
        xlabel(ax, 'Ќомер сингул€рного числа', 'FontSize', 14);
        ylabel(ax, '«начение сингул€рного числа', 'FontSize', 14);
        saveas(fig, [output_path, '√рафик svd дл€ ', files{k}, '.jpg']);
        close(fig);
        writematrix(s, [output_path, '„исла svd дл€ ', files{k}, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.txt'], 'Delimiter', 'space');  %  запись сингул€рных значений в текстовый файл
    end
end

fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), '‘айлы с сингул€рными числами успешно записаны по адресу:', output_path);