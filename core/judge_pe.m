function t_state = judge_pe(t_state,im_rgb,im_t)

pos = t_state.pos;
target_sz = t_state.target_sz;
BoxPolygon = pos2polygon1(pos,target_sz);

im_rgb = rgb2gray(im_rgb);
im_t = rgb2gray(im_t);

[optimizer, metric] = imregconfig('multimodal');
tform = imregtform(im_t, im_rgb, 'similarity', optimizer, metric);
newBoxPolygon = transformPointsForward(tform,BoxPolygon);
dist = axis_change(BoxPolygon,newBoxPolygon);
d = sqrt(dist(1,1) * dist(1,1) + dist(1,2) * dist(1,2));
target_size = sqrt(target_sz(1,1) * target_sz(1,1) + target_sz(1,2) * target_sz(1,2));
d_ratio = d/target_size;
t_state.dist_PE = dist;
t_state.target_sz_rgb = [newBoxPolygon(3,1)-newBoxPolygon(1,1),newBoxPolygon(3,2)-newBoxPolygon(1,2)];
if d_ratio > 0.04 && d_ratio < 0.194
    t_state.flag_PE = 1;
    t_state.pos_rgb = polygon2pos(newBoxPolygon,t_state.target_sz_rgb);
else
    t_state.flag_PE = 0;
    t_state.pos_rgb = pos;
end




