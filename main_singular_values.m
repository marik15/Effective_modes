% ��������� � ������ ������ ����������� ����� �� ����������� ������

path_data = 'C:\MATLAB\����������� ����\';  %  ����� � �������, � ����� ������ \
files = {'w5_1a.irc'};  %  ����� ������
t_step = 20000;  %  ���, �������
t1 = 1;  %  ������ ����������
t2 = 60001;  % ����� ����������: ����� �����, ���� ����� 'end', ���� ����� ��������� �� ����� �����, � ����� ����� ����������

% --- ���� �� ����� �������������

output_path = [path_data, '����������� �����\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  �������� ����� � ������������
end

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
ax = axes(fig);
        
for k = 1:numel(files)
    filename = [path_data, files{k}];
    [n, qVxyz_full, ~] = load_n_qVxyz_xyz(path_data, filename);  %  ��������� ������ �� .irc

    if (strcmp(t2, 'end'))
        t2 = size(qVxyz_full, 1);
    end

    for t = 0:fix((t2-t1+1)/t_step)-1  %  ���� �� ��������� ��������
        t1_cur = t1 + t*t_step;
        t2_cur = t1_cur + t_step - 1;
        
        qVxyz = qVxyz_full(t1_cur:t2_cur, :);
        E12 = sqrt_energy(qVxyz);
        s = svd(E12-mean(E12));  %  ����������� ����� � ������� ��������

        plot(ax, s);  %  ���������� �������
        xlim(ax, [1, 3*n]);
        title(ax, ['The singular values from their number for file ', files{k}, ' Time ', num2str(t1_cur), '-', num2str(t2_cur)], 'FontSize', 16, 'Interpreter', 'none');
        xlabel(ax, 'Singular value`s number', 'FontSize', 14);
        ylabel(ax, 'Singular value', 'FontSize', 14);
        saveas(fig, [output_path, '������ SVD ��� ', files{k}, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.jpg']);
        writematrix(s, [output_path, '����� SVD ��� ', files{k}, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.txt'], 'Delimiter', 'space');  %  ������ ����������� �������� � ��������� ����
    end
end

close(fig);

fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), '����� � ������������ ������� ������� �������� �� ������:', output_path);