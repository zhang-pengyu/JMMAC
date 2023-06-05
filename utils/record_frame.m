function [ im_record_rgb,im_record_t,pos_record,target_sz_record ] = record_frame(im_record_rgb,im_record_t,pos_record,target_sz_record,im_rgb,im_t,pos,target_sz)
if isempty(im_record_rgb{1})
    im_record_rgb{1} = im_rgb;
    im_record_t{1} = im_t;
    pos_record{1} = pos;
    target_sz_record{1} = target_sz;
elseif isempty(im_record_rgb{2})
    im_record_rgb{2} = im_rgb;
    im_record_t{2} = im_t;
    pos_record{2} = pos;
    target_sz_record{2} = target_sz;
elseif isempty(im_record_rgb{3})
    im_record_rgb{3} = im_rgb;
    im_record_t{3} = im_t;
    pos_record{3} = pos;
    target_sz_record{3} = target_sz;
else
    im_record_rgb{1} = im_record_rgb{2};
    im_record_rgb{2} = im_record_rgb{3};
    im_record_rgb{3} = im_rgb;
    im_record_t{1} = im_record_t{2};
    im_record_t{2} = im_record_t{3};
    im_record_t{3} = im_t;
    
    pos_record{1} = pos_record{2};
    pos_record{2} = pos_record{3};
    pos_record{3} = pos;
    target_sz_record{1} = target_sz_record{2};
    target_sz_record{2} = target_sz_record{3};
    target_sz_record{3} = target_sz;
    
end


