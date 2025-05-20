%  Возвращает данные из Excel-файла

function E_kin_rab = get_initial_data(filename, trajectory_name)
    A = readcell(filename, 'NumHeaderLines', 1);
    ind = ismember(A(:, 1), trajectory_name);
    E_kin_rab = [A{ind, 4:6}];
    %  N0 = A{ind, 7};
end