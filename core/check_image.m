function [flag,im_rgb,im_t] = check_image(im_rgb,im_t)
flag = 0;
if isempty(im_rgb) || isempty(im_rgb)
    flag = 1;
end

% if size(im_rgb,3) > 1 && rgb_params.is_color_image == false
%     im_rgb = im_rgb(:,:,1);
% end
% 
% if size(im_t,3) > 1 && t_params.is_color_image == false
%     im_t = im_t(:,:,1);
% end