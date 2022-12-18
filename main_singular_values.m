% ѕрограмма вычисл€ет сингул€рные числа и строит график от пор€дкового номера

path = 'C:\MATLAB\Ёффективные моды\';  %  папка с файлами, в конце символ \
files = {'w3_4.irc'};  %  имена файлов
t1 = 1;  %  начало траектории
t2 = 'end';  % конец траектории: целое число, либо слово 'end', если нужно посчитать до конца файла, а число строк неизвестно

% --- ниже не нужно редактировать

output_path = [path, '—ингул€рные числа\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

for k = 1:numel(files)
    filename = [path, files{k}];

    [N, qVxyz, ~] = get_matrices(filename, t1, t2);  %  считываем данные из .irc
    E12 = sqrt_energy(qVxyz);
    s = svd(E12);  %  сингул€рные числа в пор€дке убывани€

    if (strcmp(t2, 'end'))
        t2 = size(E12, 1);
    end

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);
    plot(ax, s);  %  построение графика
    xlim(ax, [1, 3*N]);
    title(ax, ['¬еличина сингул€рных чисел от их номера дл€ файла ', files{k}], 'FontSize', 16, 'Interpreter', 'none');
    xlabel(ax, 'Ќомер сингул€рного числа', 'FontSize', 14);
    ylabel(ax, '«начение сингул€рного числа', 'FontSize', 14);
    saveas(fig, [output_path, '√рафик svd дл€ ', files{k}, '.jpg']);
    close(fig);
    writematrix(s, [output_path, '„исла svd дл€ ' files{k} '.txt'], 'Delimiter', 'space');  %  запись сингул€рных значений в текстовый файл
end

fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), '‘айлы с сингул€рными числами успешно записаны по адресу:', output_path);