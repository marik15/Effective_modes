input_file = 'Result 9_vars 3 order step 500 res all';

LOAD = load(append(input_file, '.mat'));

head = {'Имя файла', 'R(0)', 'A(0)', 'B(0)', 'RMSE', 'k_1', 'k_{-1}', 'k_2', 'k_{-2}', 'k_3', 'k_{-3}'};
writecell(head, append(input_file, '.xlsx'), 'Sheet', 1, 'Range', 'A1', 'WriteMode', 'overwritesheet');
writecell(LOAD.filename, append(input_file, '.xlsx'), 'Sheet', 1, 'Range', 'A2');
data = zeros(numel(LOAD.y0_best), 10);
for row = 1:numel(LOAD.y0_best)
    data(row, 1:3) = LOAD.y0_best{row}(1, :);
    data(row, 4) = LOAD.f_vals_best{row}(1, 1);
    data(row, 5:end) = LOAD.k_best{row}(1, :);
end
writematrix(data, append(input_file, '.xlsx'), 'Sheet', 1, 'Range', 'B2');  %  записываем числовые данные во столбцы B-D

try
    excel = actxserver('Excel.Application');  %  создаем COM-объект Excel
    workbook = excel.Workbooks.Open(fullfile(pwd, append(input_file, '.xlsx')));  %  открываем файл
    sheet = workbook.Sheets.Item(1);  %  выбираем первый лист

    for col = 1:(1 + size(data, 2))
        sheet.Columns.Item(col).ColumnWidth = 15;  %  устанавливаем ширину столбцов (в пунктах)
    end

    %  выравниваем текст по центру (горизонтально и вертикально)
    usedRange = sheet.UsedRange;  %  весь заполненный диапазон
    usedRange.HorizontalAlignment = 3;  % 3 = xlCenter (горизонтально)
    usedRange.VerticalAlignment = 2;  % 2 = xlCenter (вертикально)

    %  сохраняем и закрываем
    workbook.Save();
    workbook.Close();
    excel.Quit();
    delete(excel);  %  удаляем COM-объект
catch
    warning('Не удалось настроить ширину столбцов. Проверьте, установлен ли Excel.');
end