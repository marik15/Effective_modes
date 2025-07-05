%  Возвращает список похожих по названию файлов из cell и их индексы

function [filenames, indexes] = get_similar_names_cell(names, filename)
    [startIndex, endIndex] = regexp(filename, '[a-z]+\d+_\d+[a-z]*');
    filenames = cell(0);
    indexes = [];
    for idx = 1:numel(names)
        [startIndex2, endIndex2] = regexp(names{idx}, '[a-z]+\d+_\d+[a-z]*');
        if strcmp(filename(startIndex:endIndex), names{idx}(startIndex2:endIndex2))
            filenames{end + 1} = names{idx};  %#ok<*AGROW>
            indexes(end + 1) = idx;
        end
    end
end