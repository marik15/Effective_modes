% ��������� ��������� ����������� ����� � ������ ������ �� ����������� ������

path = 'C:\MATLAB\����������� ����\';  %  ����� � �������, � ����� ������ \
files = {'w3_4.irc'};  %  ����� ������
t1 = 1;  %  ������ ����������
t2 = 'end';  % ����� ����������: ����� �����, ���� ����� 'end', ���� ����� ��������� �� ����� �����, � ����� ����� ����������

% --- ���� �� ����� �������������

output_path = [path, '����������� �����\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  �������� ����� � ������������
end

for k = 1:numel(files)
    filename = [path, files{k}];

    [N, qVxyz, ~] = get_matrices(filename, t1, t2);  %  ��������� ������ �� .irc
    E12 = sqrt_energy(qVxyz);
    s = svd(E12);  %  ����������� ����� � ������� ��������

    if (strcmp(t2, 'end'))
        t2 = size(E12, 1);
    end

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    ax = axes(fig);
    plot(ax, s);  %  ���������� �������
    xlim(ax, [1, 3*N]);
    title(ax, ['�������� ����������� ����� �� �� ������ ��� ����� ', files{k}], 'FontSize', 16, 'Interpreter', 'none');
    xlabel(ax, '����� ������������ �����', 'FontSize', 14);
    ylabel(ax, '�������� ������������ �����', 'FontSize', 14);
    saveas(fig, [output_path, '������ svd ��� ', files{k}, '.jpg']);
    close(fig);
    writematrix(s, [output_path, '����� svd ��� ' files{k} '.txt'], 'Delimiter', 'space');  %  ������ ����������� �������� � ��������� ����
end

fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), '����� � ������������ ������� ������� �������� �� ������:', output_path);