% Возвращает матрицу поворота на углы Эйлера

function R = rotation_matrix(alpha, beta, gamma)
    R = [cos(alpha)*cos(gamma)- cos(beta)*sin(alpha)*sin(gamma), -cos(gamma)*sin(alpha)-cos(alpha)*cos(beta)*sin(gamma), sin(beta)*sin(gamma);
         cos(beta)*cos(gamma)*sin(alpha)+cos(alpha)*sin(gamma), cos(alpha)*cos(beta)*cos(gamma)-sin(alpha)*sin(gamma), -cos(gamma)*sin(beta);
         sin(alpha)*sin(beta), cos(alpha)*sin(beta), cos(beta)];
end