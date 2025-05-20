%  Подготавливает вспомогательные файлы

clearvars;
close all;
clc;

path_data = 'C:\Users\zakir\Downloads\tmp\';  %  папка с irc
path_aux = 'E:\MATLAB\Эффективные моды\Вспомогательные файлы\';  %  куда сохранять

files = dir(append(path_data, '*.irc'));

for file_id = 1:numel(files)
    filename = [path_data, files(file_id).name];
    load_n_qVxyz_xyz_fs(path_aux, filename);
end