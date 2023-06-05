function [t_state,kf_state,kf_params] = judge_occ(t_state,kf_state,t_params,kf_params,im_rgb,seq)

[~, ~, scale_ind] = optimize_scores(t_state.scores_fs, t_params.newton_iterations);
sampled_scores = sample_fs(t_state.scores_fs(:,:,scale_ind));
max_score = sampled_scores(sampled_scores == max(sampled_scores(:)));

PSR = (max_score-mean(mean(sampled_scores)))/(std2(sampled_scores)^2);


if seq.frame>2
    if t_state.flag_PE
        [kf_state.feature,kf_state.patch] = extract_template_features(im_rgb, round(t_state.pos+t_state.dist_PE([2,1]))-1 ,kf_params.template_features,t_state.target_sz,t_state.init_target_sz,kf_params.use_gpu);
    else
        [kf_state.feature,kf_state.patch] = extract_template_features(im_rgb,t_state.pos,kf_params.template_features,t_state.target_sz,t_state.init_target_sz,kf_params.use_gpu);
    end
    for x = 1:length(kf_state.feature)
        res = xcorr(kf_state.feature{x}(:),kf_state.template{x}(:));
        res = gather(res);
        kf_state.max_score_feature(x) = max(res);
    end
end

%% judge occlusion
if    seq.frame>2
    if (kf_state.max_score_feature(1)/kf_params.max_score_init(1)< kf_params.thr_feature_low_1)||(kf_state.max_score_feature(2)/kf_params.max_score_init(2)< kf_params.thr_feature_low_2)...
            ||max_score < kf_params.thr_feature_low_3 || PSR < kf_params.thr_feature_low_4
        if (t_state.flagCM == 1 )||max_score > kf_params.thr_feature_high_3 || PSR > kf_params.thr_feature_high_4 || ...
                ((kf_state.max_score_feature(1)/kf_params.max_score_init(1)>kf_params.thr_feature_high_1)||(kf_state.max_score_feature(2)/kf_params.max_score_init(2)>kf_params.thr_feature_high_2)) || ...
                max(t_state.pos+t_state.target_sz/2>[size(im_rgb,1),size(im_rgb,2)]) || max(t_state.pos-t_state.target_sz/2<[1 1])
            kf_state.flagOCC = false;
        else
            kf_state.flagOCC = true;            
        end
    else
        kf_state.flagOCC = false;
    end
else
    kf_state.flagOCC = false;    
end