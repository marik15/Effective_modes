function save_U(filename, outputname)
    [N, qVxyz, xyz] = get_matrices(filename, 1, 'end');  %  считываем данные из .irc
    const = 0.529177;  %  переводим боры в ангстремы
    for i = 1:N
        qVxyz(:, 4*i-2:4*i) = qVxyz(:, 4*i-2:4*i)*const;
    end
    xyz = xyz*const;
    E12 = sqrt_energy(qVxyz);  %  считаем квадратный корень из матрицы
    [U, ~, ~] = svd(E12, 0);
    save(outputname, 'U');
end