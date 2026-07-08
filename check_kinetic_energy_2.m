%  Строит графики кинетической энергии разными способами

clearvars;  %  удалить все переменные
close all;  %  закрыть все графики
clc;  %  очистить вывод

path_data = 'D:\MATLAB\Эффективные моды\data\';  %  папка с файлами, в конце символ \
files = {'w3_1.irc';
         'w3_3a_1.irc';
         'w3_3a_2.irc';
         'w3_4a.irc'};  %  названия файлов
path_output = 'D:\MATLAB\Эффективные моды\';  %  сохранить видео

%  Построить графики:
%  Кинетической энергии по файлу - перевести в ккал/моль ОК
%  Полной и потенциальной энергии по файлу
%  По отдельным атомам
%  По эффективным модам

t1 = 1;  %  начиная с какого отсчёта по времени усреднять
t2 = 5001;  %  последний отсчёт по времени
widths = [1:10, 12:2:20, 25:5:50, 60:10:100, 150:50:500, 600:100:1000, 1200:200:4000];

% --- ниже не нужно редактировать

k_kkal_mole = 669.2841158284926;  %  коэффициент перевода а.е.м. * (бор/фс)^2 в ккал/моль: E = 0.5 * k * m * V^2;
k_kkal_mole_header = 627.5095;

output_path = [path_data, 'Kinetic Energy\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');
box(ax, 'on');

xlabel(ax, 'Время, пс');
ylabel(ax, 'Кинетическая энергия, ккал/моль');

for file_id = 1:numel(files)
    filename = [path_data, files{file_id}];
    [~, name, ~] = fileparts(filename);

    n = count_n(filename);  %  число частиц
    file = fopen(filename);
    t = 0;  %  номер измерения
    E_k_header = zeros(1, 1);  %  кинетическая энергия
    E_p_header = zeros(1, 1);  %  потенциальная энергия
    E_t_header = zeros(1, 1);  %  полная энергия

    while (~feof(file))
        t = t + 1;  %  чтение всего файла
        for i = 1:2  %  пропуск заголовков
            [~] = fgetl(file);
        end
        line = fgetl(file);
        line = line(11:end);  %  убираем значение TIME (иногда они звездочки)
        values = str2num(line);  %#ok<ST2NM>
        E_k_header(t, 1) = values(1);  %  энергия из строчки
        E_p_header(t, 1) = values(2);
        E_t_header(t, 1) = values(3);
        for j = 1:n+2
            [~] = fgetl(file);
        end
    end
    fclose(file);
    E_k_header = k_kkal_mole_header * E_k_header;
    E_p_header = k_kkal_mole * E_p_header;
    E_t_header = k_kkal_mole * E_t_header;

    [~, qVxyz_full, ~, fs] = load_n_qVxyz_xyz_fs(path_data, filename);  %  считываем данные из .irc
    T = size(qVxyz_full, 1);

    E_k_formula = zeros(size(qVxyz_full, 1), 1);
    for t = t1:t2
        for atom = 1:size(qVxyz_full, 2)/4
            m = mass_by_charge(qVxyz_full(t, 4 * atom - 3));
            V = norm(qVxyz_full(t, (4 * atom - 2):(4 * atom)));  %  переводим в боры
            E_k_formula(t) = E_k_formula(t) + 0.5 * m * (V^2) * k_kkal_mole;
        end
    end

    output_video = VideoWriter(append(path_output, name, ' t1=', num2str(t1), ' t2=', num2str(t2), '.mp4'), 'MPEG-4');  %  создание видео
    output_video.FrameRate = 2;  %  кадров в секунду
    open(output_video);

    for width_svd = widths
        E_kin_svd = zeros(size(qVxyz_full, 1), 1);
        E12 = energy_power(qVxyz_full, 0.5);
        t_range_svd = (t1 + fix(0.5 * width_svd)):(t2 - ceil(0.5 * width_svd) + 1);
        for t = t_range_svd
            time_svd = round(t + (fix(- 0.5 * width_svd):(ceil(0.5 * width_svd) - 1)));  %  диапазон времени для svd
            s = svd(E12(time_svd, :));
            E_kin_svd(t) = sum(s.^2) / numel(time_svd) * k_kkal_mole;
        end
    
        cla(ax);
        p = gobjects(3, 1);
        p(1) = plot(ax, (t1:t2) / fs * 1e+12, E_k_header(t1:t2, 1), 'LineWidth', 1);
        p(2) = plot(ax, (t1:t2) / fs * 1e+12, E_k_formula(t1:t2, 1), 'LineWidth', 1);
        p(3) = plot(ax, t_range_svd / fs * 1e+12, E_kin_svd(t_range_svd, 1), 'LineWidth', 1);
        %plot(ax, (t1:t2) / fs * 1e+12, E_p_header(t1:t2, 1), 'LineWidth', 1);
        xlim(ax, [t1, t2] / fs * 1e+12);
        title(ax, append(name, ' ширина SVD=', num2str(width_svd), ' точек, шаг ', num2str(1e+15/fs), ' фс'), 'Interpreter', 'none');
        legend(ax, p, {'$\mbox{irc file header}$', '$E_{kin.} = \sum_{k} \frac{m_{k} v_{k}^{2}}{2}$', '$E_{kin.} = \sum_{k} \sigma_{k}^{2}$'}, 'Interpreter', 'latex');
        set(ax, 'FontSize', 40);
        0;
        if width_svd == 1
            saveas(fig, append(path_output, name, ' t1=', num2str(t1), ' t2=', num2str(t2), ' width=', num2str(width_svd), '.png'));
        end
        writeVideo(output_video, getframe(fig));
    end
    close(output_video);
end