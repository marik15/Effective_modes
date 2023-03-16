% Возвращает массу всех атомов

function m = get_mass(qVxyz)
    n = size(qVxyz, 2)/4;
    m = zeros(1, n);
    for atom = 1:n
        m(atom) = mass_by_charge(qVxyz(1, 4*atom-3));  %  масса из первой строчки матрицы
    end
end