% Вычисляет момент инерции тела при повороте оператором R

function J = moment_of_inertia(m, r1, r0, angle)
    R = rotation_matrix(angle(1), angle(2), angle(3));
    R_r0 = zeros(size(r0'));
    for k = 1:numel(m)
        R_r0(3*k-2:3*k) = R*(r0(3*k-2:3*k)');  %  оператор действует на координаты каждого атома
    end
    J = 0;
    for k = 1:numel(m)
        J = J + m(k)*(norm(r1(3*k-2:3*k) - (R_r0(3*k-2:3*k)'))^2);
    end
end