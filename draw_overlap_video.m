function draw_overlap_video(A, start_arr, end_arr, path, name)
    N = size(A, 2)/3;
    fig = figure('Color', 'w', 'WindowState', 'maximized');
    ax = axes(fig);
    colorbar(ax);
    caxis(ax, [0, 1]);
    caxis(ax, 'manual');
    axis(ax, 'equal');
    hold(ax, 'on');
    view(ax, 2);
    xlim(ax, [1, 3*N]);
    ylim(ax, [1, 3*N]);
    xlabel(ax, 'Номер сингулярного вектора первого интервала');
    ylabel(ax, 'Номер сингулярного вектора второго интервала');

    video_filename = append(path, name, ' video ', string(datetime(now, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH-mm-ss')), '.mp4');
    output_Video = VideoWriter(video_filename, 'MPEG-4');  %  раскомментировать всё для создания видео
    output_Video.FrameRate = 1;  %  кадров в секунду
    open(output_Video);

    t = 1;
    image = reshape(A(t, :, :), 3*N, 3*N);
    s = surf(ax, image, 'EdgeColor', 'None');
    title(ax, append('Интеграл перекрываний участков [', num2str(start_arr(1)), '; ', num2str(end_arr(1)), '] и [', num2str(start_arr(2)), '; ', num2str(end_arr(2)), ']'));
    writeVideo(output_Video, getframe(fig));

    for t = 2:size(A, 1)
        image = reshape(A(t, :, :), 3*N, 3*N);
        set(s, 'ZData', image);
        ax.Title.String = append('Интеграл перекрываний участков [', num2str(start_arr(t)), '; ', num2str(end_arr(t)), '] и [', num2str(start_arr(t+1)), '; ', num2str(end_arr(t+1)), ']');
        writeVideo(output_Video, getframe(fig));
    end
    close(output_Video);
    close(fig);
    fprintf('\t%s\n\t%s\n\t%s\n', datestr(datetime(now, 'ConvertFrom', 'datenum')), 'Видеофайл сохранен по адресу:', video_filename);
end