%  Возвращает число атомов, матрицы скоростей и координат в борах

function [n, qVxyz, xyz, fs] = get_n_qVxyz_xyz_fs(filename)
    [n, qVxyz, xyz, fs] = get_matrices(filename, 1, 'end');  %  считываем данные из .irc (весь файл)
end