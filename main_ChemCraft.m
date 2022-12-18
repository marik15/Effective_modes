% ��������� ������ .txt-���� ��� ������ � ������������ ChemCraft

path = 'C:\MATLAB\����������� ����\';  %  ����� � �������, � ����� ������ \
files = {'w3_1.irc'};  %  ����� ������
t1 = 1;  %  ������ ���������� - ����� �����
t2 = 'end';  %  ����� ���������� - ����� �����, ���� ����� 'end', ���� ����� ��������� �� ����� �����, �� ����� ����� ����������

fs = 2E+15;  %  ������� ������������� (������� ��� � ������� �������: �������� ������������)

% --- ���� �� ����� �������������

sample = [cd, '\wx.sample'];

for file_id = 1:numel(files)
    filename = [path, files{file_id}];
    [N, qVxyz, xyz] = get_matrices(filename, t1, t2);  %  ��������� ������ �� .irc
    q = zeros(N, 1);
    for i = 1:N
        q(i) = qVxyz(1, 4*i-3);
    end
    if (isa(t2, 'double') && (t2-t1+1 < 3*N))  %#ok<BDSCI>
        fprintf('\t%s\n\t%s\n\n', '��������!', '����� ��������� [t1; t2] ������ ����� �������� �������!');
    end
    const = 0.529177;  %  ��������� ���� � ���������
    for i = 1:N
        qVxyz(:, 4*i-2:4*i) = qVxyz(:, 4*i-2:4*i)*const;
    end
    xyz = xyz*const;

    E12 = sqrt_energy(qVxyz);  %  ��������� ���������� ������ �� �������
    [U, S, V] = svd(E12, 0);

    [~, name, ~] = fileparts(filename);
    output_path = [path, '���������� ', name, '\'];
    if (~isfolder(output_path))
        mkdir(output_path);  %  �������� ����� � ������������
    end

    output_path_U = [path, '��������������� U-�����\'];
    if (~isfolder(output_path_U))
        mkdir(output_path_U);  %  �������� ����� � ���������������� �������
    end
    if (~isfile([output_path_U, name, '_U.mat']))
        save([output_path_U, name, '_U.mat'], 'U');  %  ���������� ������ ��� ���������
        fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), '���� ��� ��������� ������� �� ������:', [output_path_U, name, '_U.mat']);
    end
    write_wx_for_visualizer(sample, q, xyz, N, U, diag(S), V, fs, output_path);  %  ������ � ����
end