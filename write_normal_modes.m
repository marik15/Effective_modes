path = 'C:\MATLAB\Эффективные моды\normal_modes\';
files = {'w3.mp2';
         'w4.mp2';
         'w5.mp2'};

for k = 1:numel(files)
    filename = append(path, files{k});
    A = read_modes(filename);
    [~, name, ~] = fileparts(filename);
    file = fopen(append(name, '.txt'), 'w');
    for h = 1:size(A, 1)
        for w = 1:size(A, 2)
            fprintf(file, '%17.10E ', A(h, w));
        end
        fprintf(file, '\n');
    end
    fclose(file);
end