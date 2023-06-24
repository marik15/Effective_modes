% ������ .txt-���� ��� ������ � ���������-������������ ChemCraft

path = 'C:\MATLAB\����������� ����\';  %  ����� � �������, � ����� ������ \
files = {'w3_1.irc'};  %  ����� ������
t1 = 1;  %  ������ ���������� - ����� �����
t2 = 'end';  %  ����� ���������� - ����� �����, ���� ����� 'end', ���� ����� ��������� �� ����� �����, �� ����� ����� ����������

% ���� �� ����� �������������!

fs = 2E+15;  %  ������� ������������� (������� ��� � ������� �������: �������� ������������)

sample = [cd, '\wx.sample'];

for file_id = 1:numel(files)
    filename = [path, files{file_id}];
    [n, qVxyz, xyz] = get_n_qVxyz_xyz(filename);
    q = zeros(n, 1);
    for atom = 1:n
        q(atom) = qVxyz(1, 4*atom-3);
    end
    if (isa(t2, 'double') && (t2-t1+1 < 3*n))  %#ok<BDSCI>
        fprintf('\t%s\n\t%s\n\n', '��������!', '����� ��������� [t1; t2] ������ ����� �������� �������!');
    end

    E12 = sqrt_energy(qVxyz);  %  ��������� ���������� ������ �� �������
    [U, S, V] = svd(E12, 0);

    [~, name, ~] = fileparts(filename);
    output_path = [path, '����������\', name, '\'];
    if (~isfolder(output_path))
        mkdir(output_path);  %  �������� ����� � ������������
    end

    output_path_U = append(path, '��������������� �����\', name, '\');
    if (~isfolder(output_path_U))
        mkdir(output_path_U);  %  �������� ����� � ���������������� �������
    end
    if (~isfile([output_path_U, name, '_U.mat']))
        save([output_path_U, name, '_U.mat'], 'U');  %  ���������� ������ ��� ���������
        fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), '���� ��� ��������� ������� �� ������:', append(output_path_U, name, '_U.mat'));
    end
    write_wx_for_visualizer(sample, q, xyz, n, U, diag(S), V, fs, output_path);  %  ������ � ����
end