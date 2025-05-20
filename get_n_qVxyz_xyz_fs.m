% Возвращает число атомов, матрицы скоростей и координат

function [n, qVxyz, xyz, fs] = get_n_qVxyz_xyz_fs(filename)
    [n, qVxyz, xyz, fs] = get_matrices(filename, 1, 'end');  %  считываем данные из .irc (весь файл)
    const = 0.529177;  %  переводим боры в ангстремы
    for i = 1:n
        qVxyz(:, 4*i-2:4*i) = qVxyz(:, 4*i-2:4*i)*const;
    end
    xyz = xyz*const;
end