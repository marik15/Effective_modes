%  Работа с регулярными выражениями

clearvars;
clc;

path_aux = 'D:\MATLAB\Эффективные моды\Вспомогательные файлы\';
d = dir(path_aux);
d([d.isdir]) = [];  %  remove . and .. and all subpaths
names = {d.name}';
for idx = 1:numel(names)
    names{idx} = names{idx}(1:end-4);
end
filename = 'w4_1a_1';

[startIndex, endIndex] = regexp(filename, '[a-z]+\d+_\d+[a-z]+_');
[startIndex2, endIndex2] = regexp(filename, '[a-z]+\d+_\d+[a-z]+');
filenames = cell(0);
for idx = 1:numel(names)
    if ((~isempty(startIndex)) && (numel(names{idx}) >= endIndex) && strcmp(filename(startIndex:endIndex-1), names{idx}(startIndex:endIndex-1)))
        filenames{end + 1} = names{idx};  %#ok<*SAGROW>
    elseif ((~isempty(startIndex2)) && (numel(names{idx}) >= endIndex2) && strcmp(filename(startIndex2:endIndex2), names{idx}(startIndex2:endIndex2)))
        filenames{end + 1} = names{idx};
    end
end