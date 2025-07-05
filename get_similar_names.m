%  Возвращает список похожих по названию файлов

function [filenames, indexes] = get_similar_names(path_aux, filename)
    d = dir(path_aux);
    d([d.isdir]) = [];  %  remove . and .. and all subpaths
    names = {d.name}';
    for idx = 1:numel(names)
        names{idx} = names{idx}(1:end-4);
    end
    [filenames, indexes] = get_similar_names_cell(names, filename);
end