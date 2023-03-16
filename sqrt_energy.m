% Вычисляет корень из матрицы энергии (Внимание! Заряд нужно вручную менять на массу в mass_by_charge.m)

function E12 = sqrt_energy(qVxyz)
    T = size(qVxyz, 1);  %  число отсчетов по времени
    n = size(qVxyz, 2)/4;  %  число частиц
    E12 = zeros(T, 3*n);
    for i = 1:T
        for j = 1:n
            m = mass_by_charge(qVxyz(i, 4*j-3));  %  масса
            E12(i, 3*j-2) = sqrt(0.5*m)*qVxyz(i, 4*j-2);  %  x
            E12(i, 3*j-1) = sqrt(0.5*m)*qVxyz(i, 4*j-1);  %  y
            E12(i, 3*j) = sqrt(0.5*m)*qVxyz(i, 4*j);  %  z
        end
    end
end