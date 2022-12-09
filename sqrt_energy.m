% Вычисляет корень из матрицы энергии
function E12 = sqrt_energy(qVxyz)
    T = size(qVxyz, 1);  %  число отсчётов по времени
    N = size(qVxyz, 2)/4;  %  число частиц
    E12 = zeros(T, 3*N);
    for i = 1:T
        for j = 1:N
            m = qVxyz(i, 4*j-3);  %  масса
            if (m == 8)  %  замена 8 на 16
                m = 16;
            end
            if (m == 11)
                m = 23;
            end
            E12(i, 3*j-2) = sqrt(0.5*m)*qVxyz(i, 4*j-2);  %  x
            E12(i, 3*j-1) = sqrt(0.5*m)*qVxyz(i, 4*j-1);  %  y
            E12(i, 3*j) = sqrt(0.5*m)*qVxyz(i, 4*j);  %  z
        end
    end
end