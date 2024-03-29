% ������ .txt-���� ��� ������ � ���������-������������ ChemCraft

path_data = 'C:\MATLAB\����������� ����\';  %  ����� � �������, � ����� ������ \
files = {'w5_1a.irc'};  %  ����� ������

t1 = 1;  %  ������ ����������, �������
t2 = 60001;  %  ����� ����������, �������, ���� ����� 'end', ���� ����� ��������� �� ����� �����, �� ����� ����� ����������
t_step = 20000;  %  ���, �������

fs = 2E+15;  %  ������� ������������� (������� ��� � ������� �������: �������� ������������)

% ���� �� ����� �������������

sample = [cd, '\wx.sample'];

for file_id = 1:numel(files)
    filename = [path_data, files{file_id}];
    [n, qVxyz_full, xyz_full] = load_n_qVxyz_xyz(path_data, filename);

    [t1_id, t2_id, t_step_id] = check_t1_t2(t1, t2, t_step, size(qVxyz_full, 1), filename);
    if (t_step_id < 3*n)
        warning('\t%s\n\t%s\n\n', '��������!', '����� ��������� [t1; t2] ������ ����� �������� �������!');
    end

    q = zeros(n, 1);
    for atom = 1:n
        q(atom) = qVxyz_full(1, 4*atom-3);
    end

    for t = 0:fix((t2_id-t1_id+1)/t_step_id)-1  %  ���� �� ��������� ����������
        t1_cur = t1_id + t*t_step_id;
        t2_cur = t1_cur + t_step_id - 1;

        if isa(t2_cur, 'double')
            qVxyz = qVxyz_full(t1_cur:t2_cur, :);
            xyz = xyz_full(t1_cur:t2_cur, :);
        end
        E12 = sqrt_energy(qVxyz);  %  ��������� ���������� ������ �� �������
        [U, S, V] = svd(E12 - mean(E12), 0);  %  ������ �� ���������

        [~, name, ~] = fileparts(filename);
        output_path = [path_data, '����������\', name, '\'];
        if (~isfolder(output_path))
            mkdir(output_path);  %  �������� ����� � ������������
        end

        write_wx_for_visualizer(sample, q, xyz, n, U, diag(S), V, fs, [output_path, 'output ', num2str(t1_cur), '-', num2str(t2_cur), '.txt']);  %  ������ � ����
    end
end