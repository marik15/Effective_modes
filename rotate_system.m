% Находит лучшие углы Эйлера для минимизации момента инерции относительно точки

function d_angle = rotate_system(m, r1, r0)
    d_angle_left = fmincon(@(angle) moment_of_inertia(m, r1, r0, angle), -pi*[1, 0.5, 1], [], [], [], [], -pi*[1, 0.5, 1], pi*[1, 0.5, 1], [], optimoptions('fmincon', 'Display', 'off'));
    d_angle_middle = fmincon(@(angle) moment_of_inertia(m, r1, r0, angle), [0, 0, 0], [], [], [], [], -pi*[1, 0.5, 1], pi*[1, 0.5, 1], [], optimoptions('fmincon', 'Display', 'off'));
    d_angle_right = fmincon(@(angle) moment_of_inertia(m, r1, r0, angle), pi*[1, 0.5, 1], [], [], [], [], -pi*[1, 0.5, 1], pi*[1, 0.5, 1], [], optimoptions('fmincon', 'Display', 'off'));
    J = [moment_of_inertia(m, r1, r0, d_angle_left), moment_of_inertia(m, r1, r0, d_angle_middle), moment_of_inertia(m, r1, r0, d_angle_right)];
    [~, ind] = min(J);
    switch ind
        case 1
            d_angle = d_angle_left;
        case 2
            d_angle = d_angle_middle;
        case 3
            d_angle = d_angle_right;
    end
end