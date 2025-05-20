%  Восстанавливает матрицу методом главных компонент

clear all;
close all;
clc;

A = [0, 0, 1;
     1, -0.5, 2;
     2, -1.0, 3;
     3, -1.5, 4];

[U, S, V] = svd(A);  %  - mean(A, 1)

k = 1;
U2 = complement_matrix(U, k);
S2 = complement_matrix(S, k);
V2 = complement_matrix(V, k);
A2 = U2*S2*V2';