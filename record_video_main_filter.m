function record_video_main_filter(U, fs, t1, s, k_arr, filename_video, L_video, step_video)
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1], 'color', 'w');
    n = length(k_arr);  %  число нарисованных графиков
    [h, w] = compute_h_w(n);
    t_U = tiledlayout(fig, h, w);

    for mode_id = k_arr
        ax_U = nexttile(t_U);
        scatter(ax_U, (t1:t1+size(U, 1)-1)/fs, U(:, mode_id), 4, '.');  %  1:size(U, 1)
        xlim(ax_U, [t1, t1+size(U, 1)-1]/fs);  %  [1, size(U, 1)]
        title(ax_U, append('U_{', num2str(mode_id), '}: \lambda_{', num2str(mode_id), '} = ', num2str(s(mode_id))));
        set(ax_U, 'FontSize', 14);
    end

    output_Video = VideoWriter(filename_video, 'MPEG-4');  %  раскомментировать всё для создания видео
    output_Video.FrameRate = 10;  %  кадров в секунду
    open(output_Video);

    set(t_U.Children, 'YLimMode', 'manual');
    for k = 1:step_video:t1+size(U, 1)-L_video-1
        xlim(t_U.Children, [k, k + L_video]/fs);
        drawnow;
        pause(0.2);
        writeVideo(output_Video, getframe(fig));
    end
    close(output_Video);
    close(fig);
end