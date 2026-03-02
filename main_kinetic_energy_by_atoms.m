%  Вычисляет кинетическую энергию группы атомов в Хартри

path_data = 'D:\MATLAB\Эффективные моды\data\';  %  папка с файлами, в конце символ \
files = {'extract.irc';
         };  %  названия файлов

atoms = [1:3, 5, 8:9];  %  номера атомов

output_path = [path_data, 'Kinetic Energy by Atoms\'];  %  папка для сохранения графиков

% --- ниже не нужно редактировать

if (~isfolder(output_path))
    mkdir(output_path);  %  создание папки с результатами
end

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');
box(ax, 'on');
set(ax, 'FontSize', 40);
const = 2;  %  толщина граничных линий на графике
ax.GridLineWidth = const;
ax.LineWidth = const;

xlabel(ax, 'Time, fs');
ylabel(ax, 'Kinetic energy, Hartree');

for file_id = 1:numel(files)
    cla(ax);
    filename = [path_data, files{file_id}];
    [n, qVxyz_full, ~, fs] = load_n_qVxyz_xyz_fs(path_data, filename);

    E_kin = compute_kinetic_energy(qVxyz_full, atoms);

    t = 1e+15 * (1:size(qVxyz_full, 1)) / fs;  %  время, фс
    plot(ax, t, E_kin, 'LineWidth', 4);
    xlim(ax, t([1, end]));

    [~, name, ~] = fileparts(filename);
    saveas(fig, append(output_path, ' ', name, '.png'));
    writematrix(E_kin, append(output_path, ' ', name, '.txt'));
    fprintf('\t%s\n\t%s\n\t%s\n\t%s\n', string(datetime('now')), filename, 'Файлы с кинетической энергией успешно записаны по адресу:', output_path);
end

close(fig);


%  Возвращает кинетическую энергию группы атомов в Хартри
function E_kin = compute_kinetic_energy(qVxyz_full, atoms)
    T = size(qVxyz_full, 1);
    E_kin = zeros(T, 1);
    for t = 1:T
        for atom = atoms
            m = mass_by_charge(qVxyz_full(t, 4 * atom - 3));  %  масса, а.е.м.
            V = norm(qVxyz_full(t, (4 * atom - 2):(4 * atom)));  %  скорость, бор/фс
            E_kin(t) = E_kin(t) + 0.5 * m * (V^2);
        end
    end
    E_kin = 1.06658 * E_kin;  %  коэффициент перевода в Хартри
end