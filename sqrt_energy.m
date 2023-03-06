% Вычисляет корень из матрицы энергии (Внимание! Заряд нужно вручную менять на массу)

function E12 = sqrt_energy(qVxyz)
    T = size(qVxyz, 1);  %  число отсчетов по времени
    n = size(qVxyz, 2)/4;  %  число частиц
    E12 = zeros(T, 3*n);
    for i = 1:T
        for j = 1:n
            m = qVxyz(i, 4*j-3);  %  масса
            if (m == 8)  %  замена 8 на 16
                m = 16;
            end
            if (m == 11)  %  замена 11 на 23 и так далее
                m = 23;
            end
            E12(i, 3*j-2) = sqrt(0.5*m)*qVxyz(i, 4*j-2);  %  x
            E12(i, 3*j-1) = sqrt(0.5*m)*qVxyz(i, 4*j-1);  %  y
            E12(i, 3*j) = sqrt(0.5*m)*qVxyz(i, 4*j);  %  z
        end
    end
end