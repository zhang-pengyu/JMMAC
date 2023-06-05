function [t_state,kf_state] = t_tracking(t_state,kf_state,t_params,im_t,im_record_t,pos_record,target_sz_record,flagCM,seq)
%% tracking process using thermal image.
%
t_state.old_pos = inf(size(t_state.pos));
iter = 1;

%translation search
while iter <= t_params.refinement_iterations && any(t_state.old_pos ~= t_state.pos)
    
    if flagCM
        if seq.frame < 4
            [d,flag_motion] = FeatureMatching(im_record_t{seq.frame-1},im_t,pos_record{seq.frame-1},target_sz_record{seq.frame-1},'sift');
            if flag_motion == 1
                pos = pos_record{seq.frame-1} - d([2,1]);
                t_state.pos = pos;
                kf_state.d_total = kf_state.d_total + d;
            else
                flagCM = 0;
            end
        else
            [d,flag_motion] = FeatureMatching(im_record_t{3},im_t,pos_record{3},target_sz_record{3},'sift');
            if flag_motion == 1
                pos = pos_record{3} - d([2,1]);
                kf_state.d_total = kf_state.d_total + d;
                t_state.pos = pos;
            else
                flagCM = 0;
            end
        end
    end
    t_state.flagCM = flagCM && flag_motion;
    % Extract features at multiple resolutions
    if t_state.flagCM
        t_state.sample_pos = round(pos);
    else
        t_state.sample_pos = round(t_state.pos);
    end
    t_state.det_sample_pos = t_state.sample_pos;
    t_state.sample_scale = t_state.currentScaleFactor * t_params.scaleFactors;
    xt = extract_features(im_t, t_state.sample_pos, t_state.sample_scale, t_params.features, t_params.global_fparams, t_params.feature_extract_info);
    
    % Project sample
    xt_proj = project_sample(xt, t_state.projection_matrix);
    
    % Do windowing of features
    xt_proj = cellfun(@(feat_map, cos_window) bsxfun(@times, feat_map, cos_window), xt_proj, t_params.cos_window, 'uniformoutput', false);
    
    % Compute the fourier series
    xtf_proj = cellfun(@cfft2, xt_proj, 'uniformoutput', false);
    
    % Interpolate features to the continuous domain
    t_state.xtf_proj = interpolate_dft(xtf_proj, t_params.interp1_fs, t_params.interp2_fs);
    
    % Compute convolution for each feature block in the Fourier domain
    % and the sum over all blocks.
    t_state.scores_fs_feat{t_params.k1} = sum(bsxfun(@times, t_state.hf_full{t_params.k1}, t_state.xtf_proj{t_params.k1}), 3);
    scores_fs_sum = t_state.scores_fs_feat{t_params.k1};
    for k = t_params.block_inds
        t_state.scores_fs_feat{k} = sum(bsxfun(@times, t_state.hf_full{k}, t_state.xtf_proj{k}), 3);
        scores_fs_sum(1+t_params.pad_sz{k}(1):end-t_params.pad_sz{k}(1), 1+t_params.pad_sz{k}(2):end-t_params.pad_sz{k}(2),1,:) = ...
            scores_fs_sum(1+t_params.pad_sz{k}(1):end-t_params.pad_sz{k}(1), 1+t_params.pad_sz{k}(2):end-t_params.pad_sz{k}(2),1,:) + ...
            t_state.scores_fs_feat{k};
    end

    t_state.scores_fs = permute(gather(scores_fs_sum), [1 2 4 3]);
    iter = iter + 1;
end
    [trans_row, trans_col, t_state.scale_ind] = optimize_scores(t_state.scores_fs, t_params.newton_iterations);
    t_state.translation_vec = [trans_row, trans_col] .* (t_params.img_support_sz./t_params.output_sz) * t_state.currentScaleFactor * t_params.scaleFactors(t_state.scale_ind);
end
