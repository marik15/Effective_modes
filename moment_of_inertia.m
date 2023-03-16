% Вычисляет момент инерции тела при повороте оператором R

function J = moment_of_inertia(m, r1, r0, angle)
    R = rotation_matrix(angle(1), angle(2), angle(3));
    Rr_0 = zeros(size(r0'));
    for k = 1:numel(m)/3
        Rr_0(3*k-2:3*k) = R*(r0(3*k-2:3*k)');
    end
    J = m*(((r1') - Rr_0).^2);  %  оператор действует на все 3*n координат
end