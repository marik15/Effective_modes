%  Вычисляет скалярные произведения выбранных векторов

clearvars;
close all;
clc;

path_data = 'C:\MATLAB\Эффективные моды\Вспомогательные файлы\';
path_output= 'C:\MATLAB\Эффективные моды\Скалярные произведения\';

%{
file = {{1, 'h2o_I_04'};  %  10001
        {1, 'h2o_II_06'};  %  10001
        {2, 'h2o_IV_09'};  %  10001
        {1, 'h2o_IV_13'}};  %  10001
        %{1, 'h2o_V_05'}};  %  5001
%}

%{
file = {%{2, 'h2o_II_01'};  %  10001
         %{2, 'h2o_III_01'};  %  10001
         %{2, 'h2o_III_03'}};  %  10001
         {1, 'h2o_VI_02'};  %  5001
         {1, 'h2o_VI_08'};  %  5001
         {1, 'h2o_VI_14'};  %  5001
         {3, 'h2o_V_04'};  %  5001
         {3, 'h2o_V_10'}};  %  5001
%}

%{
file = {{2, 'h2o_I_04'};  %  10001
        {1, 'h2o_III_07'}};  %  10001
%}

%{
file = {{1, 'h2o_V_07'};  %  5001
        {1, 'h2o_V_12'}};  %  5001
%}

%{
file = {{1, 'h2o_II_01'};  %  10001
        {2, 'h2o_I_01'}};  %  7450
%}

%{
file = {{1, 'h2o_II_11'};  %  10001
        {1, 'h2o_I_06'}};  %  10001
%}

%{
file = {{1, 'h2o_III_02'};  %  10001
        {1, 'h2o_V_03'}};  %   5001
%}

%%{
file = {{1, 'h2o_III_11'};  %  10001
        {2, 'h2o_I_06'}};  %  10001
%%}

%{
file = {{1, 'h2o_II_01'};  %  10001
        {1, 'h2o_V_13'}};  %  5001
%}

U = zeros(10001, size(file, 1));

for id = 1:size(file, 1)
    LOAD = load(append(path_data, file{id}{2}, '\', file{id}{2}, '.mat'));
    E12_full = sqrt_energy(LOAD.qVxyz_full);
    T = E12_full;  %  .*E12;
    [U1, S1, V1] = svd(T - mean(T), 0);
    U(:, id) = U1(:, file{id}{1});
end

dp = zeros(size(file, 1), size(file, 1));

for i = 1:size(file, 1)
    dp(i, i) = 1;
    for j = i+1:size(file, 1)
        dp(i, j) = dot(U(:, i), U(:, j));
        dp(j, i) = dp(i, j);
        fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
        ax = axes(fig);
        hold(ax, 'on');
        p1 = plot(ax, 1:size(U, 1), U(:, i));
        p2 = plot(ax, 1:size(U, 1), U(:, j));
        xlim(ax, [1, size(U, 1)]);
        title(ax, append('Scalar product = ', num2str(dp(i, j))));
        xlabel(ax, 'Время, номер отсчета');
        legend(ax, [p1, p2], {append(file{i}{2}, ' U_{', num2str(file{i}{1}), '}'), append(file{j}{2}, ' U_{', num2str(file{j}{1}), '}')}, 'Interpreter', 'None', 'location', 'best');
        set(ax, 'FontSize', 14);
        saveas(fig, append(path_output, file{i}{2}, ' U_', num2str(file{i}{1}), file{j}{2}, ' U_', num2str(file{j}{1}), '.png'));
        close(fig);
    end
end

disp(dp);