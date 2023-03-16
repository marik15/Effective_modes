% Вращает систему как единое целое на углы Эйлера для минимизации момента инерции относительно точки

function angle = rotate_system(m, r1, r0, alpha_init)
    angle = fmincon(@(angle) moment_of_inertia(m, r1, r0, angle), alpha_init, [], [], [], [], [0, 0, 0], 2*pi*[1, 1, 1], [], optimoptions('fmincon', 'Display', 'off'));
end