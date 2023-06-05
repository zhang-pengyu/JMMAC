function [det_state, det_params] = det_init(t_state,t_params,det_params,im_rgb,seq)
det_state.haveObj = 0;
targetLoc = seq.targetLoc;
gparams.use_mexResize=true;
sample2=sample_patch(im_rgb,t_state.pos,t_state.target_sz * 2,t_state.target_sz * 2,gparams);
gray2=mean(sample2(:));
det_params.net = loadModel(det_params) ;
frame_1_sample=sample_patch(im_rgb,t_state.pos,t_params.img_sample_sz,t_params.img_sample_sz,gparams);
det_params.pr_center=det_params.pr_center_no_occ;
det_params.last_area=t_state.target_sz(1)*t_state.target_sz(2);
[roi_table_frame_1,confidence_frame_1] = ssd(det_params.net,frame_1_sample,det_params);
left_x = roi_table_frame_1(:,1) * size(frame_1_sample, 2) ; 
left_y = roi_table_frame_1(:,2) * size(frame_1_sample, 1) ;
right_x= roi_table_frame_1(:,3) * size(frame_1_sample, 2); 
right_y = roi_table_frame_1(:,4) * size(frame_1_sample, 1);
center_x=round((left_x+right_x)/2);
center_y=round((left_y+right_y)/2);
ww=right_x-left_x+1;
hh=right_y-left_y+1;
center_pos=t_params.img_sample_sz/2;
sub_x=center_x-center_pos(2);
sub_y=center_y-center_pos(1);
obj_pos_x=t_state.pos(2)+sub_x;
obj_pos_y=t_state.pos(1)+sub_y;
left_x=obj_pos_x-ww/2;
left_y=obj_pos_y-hh/2;
roi=[left_x,left_y,ww,hh];
roi=round(roi);
iou_frame_1=overlap_ratio(roi,targetLoc);
if ((confidence_frame_1>0.83 && iou_frame_1>0.73)||confidence_frame_1>0.95) && gray2<185
    det_state.flagDET=1;
else
    det_state.flagDET=0;
end
%% Train a bbox regressor
if(det_params.bbreg && det_state.flagDET)
    
    det_params.imgSize=size(im_rgb);
    rng(det_params.s1,'twister');
    s1=rng;
    rng(det_params.s2,'twister');
    s2=rng;
    rng(det_params.s3,'twister');
    s3=rng;
    pos_examples = gen_samples('uniform_aspect', targetLoc, det_params.bbreg_nSamples*10, det_params, 0.3, 10, s1,s2,s3);
    r = overlap_ratio(pos_examples,targetLoc);
    pos_examples = pos_examples(r>0.6,:);
    pos_examples=unique(pos_examples,'rows');
    rng(s1);
    pos_examples = pos_examples(randsample(end,min(det_params.bbreg_nSamples,end)),:);
    det_params.net_conv=get_net_conv(det_params);
    feat_conv = mdnet_features_convX(det_params.net_conv, im_rgb, pos_examples, det_params);
    X = permute(gather(feat_conv),[4,3,1,2]);
    X = X(:,:);
    bbox = pos_examples;
    bbox_gt = repmat(targetLoc,size(pos_examples,1),1);
    disp('start bbreg');
    det_state.bbox_reg = train_bbox_regressor(X, bbox, bbox_gt);
    disp('end bbreg');
end