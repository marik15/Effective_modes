% Считывает среднюю кинетическую энергию, указанную в шапке .irc-файла

path_data = 'D:\MATLAB\Эффективные моды\data\';  %  папка с файлами, в конце символ \
files = {'w3_1.irc'};  %  названия файлов

t1 = 1;  %  начиная с какого отсчёта по времени усреднять
t2 = 5001;  %  последний отсчёт по времени
t_step = 5000;  %  шаг, отсчеты

% --- ниже не нужно редактировать

output_path = [path_data, 'Kinetic Energy\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');
box(ax, 'on');

xlabel(ax, 'Время, номер отсчета');
ylabel(ax, 'Кинетическая энергия');
%const = 2;  %  толщина граничных линий на графике
%ax.GridLineWidth = const;
%ax.LineWidth = const;

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
        line = line(11:end);  %  убираем значение TIME (иногда они звездочки)
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
        title(ax, ['Полная кинетическая энергия для файла ', files{k}, ', среднее = ', num2str(mean(energy(t1_cur:t2_cur)))], 'Interpreter', 'None');

        m = mean(energy(t1_cur:t2_cur));
        plot(ax, [t1_cur, t2_cur], [m, m], 'r');
        set(ax, 'FontSize', 40);
        
        saveas(fig, [output_path, 'Kinetic Energy ', name, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.jpg']);

        %file2 = fopen([output_path, 'Kinetic Energy ', name, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.dat'], 'w');
        %for i = t1_cur:t2_cur
        %    fprintf(file2, '%8u   %10.4e\n', i, energy(i));
        %end
        %fclose(file2);
    end
end

close(fig);

fprintf('\t%s\n\t%s\n\t%s\n', string(datetime('now')), 'Файлы с кинетической энергией успешно записаны по адресу:', output_path);