% Программа вычисляет среднюю кинетическую энергию, указанную в шапке .irc-файла

path = 'C:\MATLAB\Эффективные моды\';  %  папка с файлами, в конце символ \
files = {%'w4_1.irc';
        %'w4_2.irc';
        %'w3_3.irc';
        'w3_4.irc';
         %'w8_5.irc';
         %'w8_6.irc';
         %'w8_7.irc';
         };  %  названия файлов

t1 = 1;  %  начиная с какого отсчёта по времени усреднять
t2 = 100000;  %  последний отсчёт по времени

% --- ниже не нужно редактировать

output_path = [path, 'Kinetic Energy\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

for k = 1:size(files, 1)
    filename = files{k};

    N = count_n([path, filename]);  %  число частиц
    file = fopen([path, filename]);
    t = 0;  %  номер измерения
    energy = zeros(1, 1);  %  массив энергий

    while (~feof(file))
        t = t + 1;
        for i = 1:2  %  пропуск заголовков
            [~] = fgetl(file);
        end
        line = fgetl(file);
        line = line(11:end);  %  убираем значение TIME
        values = str2num(line);  %#ok<ST2NM>
        energy(t, 1) = values(1);  %  энергия из строчки
        for j = 1:N+2
            [~] = fgetl(file);
        end
    end
    fclose(file);

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);
    plot(ax, t1:t2, energy(t1:t2), 'b');
    xlim(ax, [t1, t2]);
    title(ax, ['Dependence of the total kinetic energy on time for the file ', filename, ', mean = ', num2str(mean(energy(t1:t2)))], 'Interpreter', 'None');
    xlabel(ax, 'Time, countdown number');
    ylabel(ax, 'Kinetic energy');
    hold(ax, 'on');
    m = mean(energy(t1:t2));
    plot(ax, [t1, t2], [m, m], 'r');
    hold(ax, 'off');
    saveas(fig, [output_path, 'Kinetic Energy ', filename, '.jpg']);
    close(fig);

    file2 = fopen([output_path, 'Kinetic Energy ', filename, '.dat'], 'w');
    for i = t1:t2
        fprintf(file2, '%8u   %10.4e\n', i, energy(i));
    end
    fclose(file2);
end

fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Файлы с кинетической энергией успешно записаны по адресу:', output_path);