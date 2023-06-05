function seq = visualization_rgbt(t_state,det_state,kf_state,im,seq)

rect_position_vis_t = [t_state.pos([2,1]) - (t_state.target_sz([2,1]) - 1)/2, t_state.target_sz([2,1])];
im_to_show = double(im)/255;
if size(im_to_show,3) == 1
    im_to_show = repmat(im_to_show, [1 1 3]);
end
if seq.frame == 1
    seq.fig_handle = figure('Name', 'Tracking');
    imagesc(im_to_show);
    hold on;  
    rectangle('Position',rect_position_vis_t, 'EdgeColor','g', 'LineWidth',2);
    text(10, 10, int2str(seq.frame), 'color', [0 1 1]);
    axis off;axis image;set(gca, 'Units', 'normalized', 'Position', [0 0 1 1])
else
    figure(seq.fig_handle);
    imagesc(im_to_show);
    hold on;
    if kf_state.flagOCC
        rectangle('Position',rect_position_vis_t, 'EdgeColor','b', 'LineWidth',2);
    elseif det_state.haveObj
        rectangle('Position',rect_position_vis_t, 'EdgeColor','m', 'LineWidth',2);
    elseif t_state.flagCM
        rectangle('Position',rect_position_vis_t, 'EdgeColor','r', 'LineWidth',2);
    else
        rectangle('Position',rect_position_vis_t, 'EdgeColor','g', 'LineWidth',2);
    end
end
text(10, 10, int2str(seq.frame), 'color', [0 1 1]);
drawnow
end
