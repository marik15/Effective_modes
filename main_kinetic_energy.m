% Вычисляет среднюю кинетическую энергию, указанную в шапке .irc-файла

path_data = 'C:\MATLAB\Эффективные моды\';  %  папка с файлами, в конце символ \
files = {%'w4_1.irc';
         %'w4_2.irc';
         %'w3_3.irc';
         %'w3_4.irc';
         %'w8_5.irc';
         %'w8_6.irc';
         %'w8_7.irc';
         'w5_1a.irc';
         };  %  названия файлов

t_step = 20000;  %  шаг, отсчеты
t1 = 1;  %  начиная с какого отсчёта по времени усреднять
t2 = 60001;  %  последний отсчёт по времени

% --- ниже не нужно редактировать

output_path = [path_data, 'Kinetic Energy\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);

for k = 1:numel(files)
    filename = [path_data, files{k}];
    [~, name, ~] = fileparts(filename);

    n = count_n(filename);  %  число частиц
    file = fopen(filename);
    t = 0;  %  номер измерения
    energy = zeros(1, 1);  %  массив энергий

    while (~feof(file))
        t = t + 1;  %  чтение всего файла
        for i = 1:2  %  пропуск заголовков
            [~] = fgetl(file);
        end
        line = fgetl(file);
        line = line(11:end);  %  убираем значение TIME
        values = str2num(line);  %#ok<ST2NM>
        energy(t, 1) = values(1);  %  энергия из строчки
        for j = 1:n+2
            [~] = fgetl(file);
        end
    end
    fclose(file);

    for t = 0:fix((t2-t1+1)/t_step)-1  %  цикл по временным участкам
        t1_cur = t1 + t*t_step;
        t2_cur = t1_cur + t_step - 1;
        plot(ax, t1_cur:t2_cur, energy(t1_cur:t2_cur), 'b');
        xlim(ax, [t1_cur, t2_cur]);
        title(ax, ['Dependence of the total kinetic energy on time for the file ', files{k}, ', mean = ', num2str(mean(energy(t1_cur:t2_cur)))], 'Interpreter', 'None');
        xlabel(ax, 'Time, countdown number');
        ylabel(ax, 'Kinetic energy');
        hold(ax, 'on');
        m = mean(energy(t1_cur:t2_cur));
        plot(ax, [t1_cur, t2_cur], [m, m], 'r');
        hold(ax, 'off');
        saveas(fig, [output_path, 'Kinetic Energy ', name, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.jpg']);

        file2 = fopen([output_path, 'Kinetic Energy ', name, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.dat'], 'w');
        for i = t1_cur:t2_cur
            fprintf(file2, '%8u   %10.4e\n', i, energy(i));
        end
        fclose(file2);
    end
end

close(fig);

fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файлы с кинетической энергией успешно записаны по адресу:', output_path);