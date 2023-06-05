function [seq, im_rgb, im_t] = get_sequence_frame(seq)

seq.frame = seq.frame + 1;
if strcmpi(seq.format, 'otb')
    
    if seq.frame > seq.num_frames
        im_rgb = [];
        im_t = [];
    else
        im_rgb = imread(seq.image_files{seq.frame,2});
        im_t = imread(seq.image_files{seq.frame,1});
    end
elseif strcmpi(seq.format, 'rgbt')
    [seq.handle, image_file] = seq.handle.frame(seq.handle);
    if isempty(image_file)
        im_rgb = [];
        im_t = [];
    else
        im_rgb = imread(image_file{1});
        im_t = imread(image_file{2});
    end
else
    error('Uknown sequence format');
end