%  Вычисляет N_eff(t) при разных ширинах скользящего окна

clearvars;
close all;
clc;

path_data = 'D:\MATLAB\Эффективные моды\data\';

files = {'w3_1a.irc';
         'w3_2a.irc';
         'w3_3a.irc';
         'w3_3a_1.irc';
         'w3_3a_2.irc';
         'w3_4a.irc'};

window_widths = [1:19, 20:2:48, 50:5:95, 100:10:200, 200:20:500, 500:50:950, 1000:100:1800, 2000:200:10000];  %  ширины окон, отсчеты

% -------------------------------------------------------------------------
% Интервал расчета
% -------------------------------------------------------------------------

t1_user = 'start';      %  номер отсчета или число пикосекунд
t1_unit = 'ps';         %  'samples' или 'ps'; для t1_user = 'start' игнорируется

t2_user = 5;            %  'end', число отсчетов или число пикосекунд
t2_unit = 'ps';         %  'samples' или 'ps'; для t2_user = 'end' игнорируется

center_data = true;     % false: SVD(E12), true: SVD(E12 - mean(E12))

stride = 1;             % шаг скольжения окна, отсчеты

k_kkal_mole = 627.5095; % коэффициент перевода в ккал/моль

output_path = fullfile(path_data, 'N_eff');
if ~isfolder(output_path)
    mkdir(output_path);
end

for file_id = 1:numel(files)
    filename = fullfile(path_data, files{file_id});
    [~, name, ~] = fileparts(filename);

    [~, qVxyz_full, ~, fs] = load_n_qVxyz_xyz_fs(path_data, filename);

    n_frames = size(qVxyz_full, 1);

    t1 = parse_time_user(t1_user, t1_unit, n_frames, fs, 't1', 'start');
    t2 = parse_time_user(t2_user, t2_unit, n_frames, fs, 't2', 'end');

    if t1 < 1 || t1 > n_frames
        error('t1 должен быть в диапазоне от 1 до %d.', n_frames);
    end

    if t2 < 1 || t2 > n_frames
        error('t2 должен быть в диапазоне от 1 до %d.', n_frames);
    end

    if t2 < t1
        error('t2 меньше t1: t1 = %d, t2 = %d.', t1, t2);
    end

    n_used = t2 - t1 + 1;

    t1_ps_actual = (t1 - 1) / fs * 1e12;
    t2_ps_actual = (t2 - 1) / fs * 1e12;
    t_total_ps = (n_used - 1) / fs * 1e12;

    fprintf('\n%s\n', name);
    fprintf('Используем отсчеты: %d ... %d\n', t1, t2);
    fprintf('Временной интервал: %.6g ... %.6g пс\n', t1_ps_actual, t2_ps_actual);
    fprintf('Число отсчетов: %d\n', n_used);
    fprintf('Длина интервала: %.6g пс\n', t_total_ps);

    N_all = cell(numel(window_widths), 1);
    time_all = cell(numel(window_widths), 1);

    %  считаем все N_eff(t)

    for w_id = 1:numel(window_widths)

        W = window_widths(w_id);

        if W > n_used
            warning('Окно W=%d больше длины траектории. Пропускаем.', W);
            N_all{w_id} = NaN;
            time_all{w_id} = NaN;
            continue;
        end

        t_starts = t1:stride:(t2 - W + 1);

        N_eff_arr = zeros(numel(t_starts), 1);
        time_arr = zeros(numel(t_starts), 1);

        for idx = 1:numel(t_starts)

            t1_cur = t_starts(idx);
            t2_cur = t1_cur + W - 1;

            qVxyz = qVxyz_full(t1_cur:t2_cur, :);

            E12 = energy_power(qVxyz, 0.5);

            if center_data && W ~= 1
                E12 = E12 - mean(E12, 1);
            end

            s = svd(E12, 0);

            s_energy = s.^2 / size(E12, 1) * k_kkal_mole;  %  собственные значения, соответствующие энергии мод

            N_eff_arr(idx) = count_N_eff(s_energy);

            %  время ставим в центр окна
            %  отсчет 1 соответствует времени 0
            time_arr(idx) = ((t1_cur - 1) + 0.5 * (W - 1)) / fs * 1e12;  %  пс
        end

        N_all{w_id} = N_eff_arr;
        time_all{w_id} = time_arr;

        fprintf('W = %d: рассчитано %d точек\n', W, numel(N_eff_arr));
    end

    avg_N = NaN(numel(window_widths), 1);

    for w_id = 1:numel(window_widths)
        avg_N(w_id) = mean(N_all{w_id}, 'omitnan');
    end

    fig = figure('units', 'normalized', ...
                 'outerposition', [0, 0, 1, 1], ...
                 'color', 'w');

    ax = axes(fig);
    hold(ax, 'on');
    grid(ax, 'on');
    box(ax, 'on');

    plot(ax, window_widths * 1e12 / fs, avg_N, 'LineWidth', 1, 'Marker', 'o');

    ylim(ax, [1, Inf]);

    title(ax, sprintf('%s анализ: %.6g...%.6g пс', name, t1_ps_actual, t2_ps_actual), 'Interpreter', 'none');
    xlabel(ax, 'Ширина усреднения, пс');
    ylabel(ax, '$N_{eff}$', 'Interpreter', 'latex');
    set(ax, 'FontSize', 40);

    saveas(fig, fullfile(output_path, [name, '.png']));
    close(fig);
end


% Локальная функция: перевод t_user в номер отсчета

function t = parse_time_user(t_user, t_unit, n_frames, fs, var_name, bound_type)

    if ischar(t_user) || isstring(t_user)

        t_str = char(strtrim(t_user));

        if strcmpi(t_str, 'end') && strcmpi(bound_type, 'end')
            t = n_frames;
            return;
        end

        if strcmpi(t_str, 'start') && strcmpi(bound_type, 'start')
            t = 1;
            return;
        end

        if strcmpi(bound_type, 'end')
            error('Если %s задан строкой, допустимо только значение ''end''.', var_name);
        else
            error('Если %s задан строкой, допустимо только значение ''start''.', var_name);
        end
    end

    if ~isscalar(t_user) || ~isnumeric(t_user) || ~isfinite(t_user)
        error('%s должен быть числом.', var_name);
    end

    switch lower(char(t_unit))

        case {'samples', 'sample', 'frames', 'frame', 'idx', 'index', 'отсчеты', 'отсчет'}
            %  t_user — номер отсчета
            t = round(t_user);

        case {'ps', 'picoseconds', 'пс', 'пикосекунды'}
            %  t_user — время в пикосекундах.
            %  Считаем, что отсчет 1 соответствует времени 0.
            t_ps = t_user;

            if strcmpi(bound_type, 'start')
                %  первый отсчет, который не раньше заданного времени
                t = ceil(t_ps * 1e-12 * fs) + 1;
            elseif strcmpi(bound_type, 'end')
                %  последний отсчет, который не позже заданного времени
                t = floor(t_ps * 1e-12 * fs) + 1;
            else
                error('bound_type должен быть ''start'' или ''end''.');
            end

        otherwise
            error('%s_unit должен быть ''samples'' или ''ps''.', var_name);
    end

    t = max(1, min(t, n_frames));
end