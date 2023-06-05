function [t_state,det_state,t_params] = process_det(t_state,kf_state,det_state,t_params,det_params,im_rgb)

if ~t_state.flagCM && det_state.flagDET
    
    img_sample_sz2  = t_params.feature_extract_info.img_sample_sizes{1};
    if kf_state.flagOCC
        img_sample_sz2=img_sample_sz2*1.2;
    end
    search_region=sample_patch(im_rgb,t_state.pos,img_sample_sz2,img_sample_sz2,t_params.global_fparams);
    if ~kf_state.flagOCC
        det_params.pr_center=det_params.pr_center_no_occ;
    else
        det_params.pr_center=det_params.pr_center_occ;
    end
    [roi_table,det_state.confidence] = ssd(det_params.net,search_region,det_params);
    if det_state.confidence > det_params.confidence
        det_state.haveObj = 1;
    else
        det_state.haveObj = 0;
    end
else
    det_state.haveObj = 0;
    t_params.use_detection_sample = true;
end

if det_state.haveObj
    left_x = roi_table(:,1) * size(search_region, 2) ;
    left_y = roi_table(:,2) * size(search_region, 1) ;
    right_x= roi_table(:,3) * size(search_region, 2);
    right_y = roi_table(:,4) * size(search_region, 1);
    center_x=round((left_x+right_x)/2);
    center_y=round((left_y+right_y)/2);
    center_pos=round(img_sample_sz2/2);
    if (center_pos(2)<right_x && center_pos(2)>left_x) && (center_pos(1)<right_y && center_pos(1)>left_y)
        det_state.haveObj=1;
    elseif kf_state.flagOCC
        det_state.haveObj=1;
    else
        det_state.haveObj=0;
    end
    if det_state.haveObj
        obj_w = round(right_x-left_x+1);
        obj_h = round(right_y-left_y+1);
        search_region_center=round(img_sample_sz2/2);
        sub_x=center_x-search_region_center(2);
        sub_y=center_y-search_region_center(1);
        obj_pos_x= t_state.pos(2)+sub_x;
        obj_pos_y= t_state.pos(1)+sub_y;
        center_dist=sqrt((obj_pos_x-t_state.pos(2)+1).* (obj_pos_x-t_state.pos(2)+1)+(obj_pos_y-t_state.pos(1)+1).*(obj_pos_y-t_state.pos(1)+1));
        sz_area = obj_h * obj_w / (t_state.target_sz(2) * t_state.target_sz(1));
        sz_scale = obj_w * t_state.target_sz(1) / (obj_h * t_state.target_sz(2));
        scale_sub_w=abs(sub_x)/t_state.target_sz(2);
        scale_sub_h=abs(sub_y)/t_state.target_sz(1);
        scale_w=obj_w/t_state.target_sz(2);
        scale_h=obj_h/t_state.target_sz(1);
        if sz_area<1
            sz_area=1.0/sz_area;
        end;
        if sz_scale<1
            sz_scale=1.0/sz_scale;
        end;
        if scale_w<1
            scale_w=1.0/scale_w;
        end;
        if scale_h<1
            scale_h=1.0/scale_h;
        end;
        if (sz_area<2.5) && (sz_scale<3.0) && scale_w<det_params.scale_ && scale_h<det_params.scale_ && scale_sub_w<det_params.scale_sub_all && scale_sub_h<det_params.scale_sub_all
            if kf_state.flagOCC || (~kf_state.flagOCC && center_dist<40 && scale_sub_w<det_params.scale_sub && scale_sub_h<det_params.scale_sub)
                t_state.pos(2) = obj_pos_x;
                t_state.pos(1) = obj_pos_y;
                target_sz_detection = [obj_h,obj_w];
                t_params.use_detection_sample = false;
            else
                det_state.haveObj = 0;
            end
        else
            det_state.haveObj = 0;
        end
    end
    %%  bbox regression
    if(det_params.bbreg && det_state.haveObj)
        tl = t_state.pos -(target_sz_detection)/2;
        bbox_ = [tl(2),tl(1),target_sz_detection(2),target_sz_detection(1)];
        bbox_= round(bbox_);
        feat_conv = mdnet_features_convX(det_params.net_conv, im_rgb, bbox_, det_params);
        X = permute(gather(feat_conv),[4,3,1,2]);
        X_ = X(:,:);
        pred_boxes = predict_bbox_regressor(det_state.bbox_reg.model, X_, bbox_);
        pred_boxes = round(pred_boxes);
        target_sz1 = [pred_boxes(:,4),pred_boxes(:,3)];
        pos1 = [pred_boxes(:,2),pred_boxes(:,1)];
        pos1 = round(pos1+(target_sz1)/2);
        det_state.pos = pos1;
        det_state.obj_w = target_sz1(2);
        det_state.obj_h = target_sz1(1);

        t_state.pos = det_state.pos;
        t_state.scale_change_factor = 1;
    end
end