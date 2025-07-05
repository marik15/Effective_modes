%  Возвращает индекс, по которому найдена строка

function idx = get_idxs(arr, str)
    idx = [];
    flag = false;
    k = 0;
    while ((~flag) && (k < numel(arr)))
        k = k + 1;
        flag = strcmp(arr{k}, str);
        if (flag)
            idx = k;
        end
    end
end