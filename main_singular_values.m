% ��������� � ������ ������ ����������� ����� �� ����������� ������

path_data = 'C:\MATLAB\����������� ����\';  %  ����� � �������, � ����� ������ \
files = {'w5_1a.irc'};  %  ����� ������
t_step = 20000;  %  ���, �������
t1 = 1;  %  ������ ����������
t2 = 100000;  % ����� ����������: ����� �����, ���� ����� 'end', ���� ����� ��������� �� ����� �����, � ����� ����� ����������

% --- ���� �� ����� �������������

output_path = [path_data, '����������� �����\'];
if (~isfolder(output_path))
    mkdir(output_path);  %  �������� ����� � ������������
end

for k = 1:numel(files)
    filename = [path_data, files{k}];

    for t = 0:fix((t2-t1+1)/t_step)-1  %  ���� �� ��������� ��������
        t1_cur = t1 + t*t_step;
        t2_cur = t1_cur + t_step - 1;
        [n, qVxyz_full, ~] = load_n_qVxyz_xyz(path_data, filename);  %  ��������� ������ �� .irc
        qVxyz = qVxyz_full(t1_cur:t2_cur, :);
        E12 = sqrt_energy(qVxyz);
        s = svd(E12-mean(E12));  %  ����������� ����� � ������� ��������

        if (strcmp(t2, 'end'))
            t2 = size(E12, 1);
        end

        fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
        ax = axes(fig);
        plot(ax, s);  %  ���������� �������
        xlim(ax, [1, 3*n]);
        title(ax, ['�������� ����������� ����� �� �� ������ ��� ����� ', files{k}], 'FontSize', 16, 'Interpreter', 'none');
        xlabel(ax, '����� ������������ �����', 'FontSize', 14);
        ylabel(ax, '�������� ������������ �����', 'FontSize', 14);
        saveas(fig, [output_path, '������ svd ��� ', files{k}, '.jpg']);
        close(fig);
        writematrix(s, [output_path, '����� svd ��� ', files{k}, ' ', num2str(t1_cur), '-', num2str(t2_cur), '.txt'], 'Delimiter', 'space');  %  ������ ����������� �������� � ��������� ����
    end
end

fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), '����� � ������������ ������� ������� �������� �� ������:', output_path);