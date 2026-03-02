%  Вычисляет кинетическую энергию по формуле E=mV^2/2

clearvars;
close all;
clc;

path_aux = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\';

files = dir(append(path_aux, '*.mat'));

file_id = 1;
LOAD = load(append(files(file_id).folder, '\', files(file_id).name));
qVxyz_full = LOAD.qVxyz_full;
t = 1;
E = 0;
for atom = 1:size(qVxyz_full, 2)/4
    m = mass_by_charge(qVxyz_full(t, 4 * atom - 3));
    V = norm(qVxyz_full(t, (4 * atom - 2):(4 * atom)));
    E = E + 0.5*m*(V^2);
end

E12 = energy_power(qVxyz_full, 0.5);
t = 1:1000;
s = svd(E12(t, :));
E_kin = sum(s.^2)/numel(t)*(1.660539e-17)*(6.02214199e+23)/4200
sum(s.^2)/numel(t)*(1e+4)/4.2