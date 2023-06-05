function [state,kf_state,params,kf_params] = t_updating(state,kf_state,params,kf_params,im_rgb,im,seq)

if seq.frame == 1
    
    sample_pos = round(state.pos);
    sample_scale = state.currentScaleFactor;
    
    xl = extract_features(im, sample_pos, state.currentScaleFactor, params.features, params.global_fparams, params.feature_extract_info);
    
    % Do windowing of features
    xlw = cellfun(@(feat_map, cos_window) bsxfun(@times, feat_map, cos_window), xl, params.cos_window, 'uniformoutput', false);
    
    % Compute the fourier series
    xlf = cellfun(@cfft2, xlw, 'uniformoutput', false);
    
    % Interpolate features to the continuous domain
    xlf = interpolate_dft(xlf, params.interp1_fs, params.interp2_fs);
    
    % New sample to be added
    xlf = compact_fourier_coeff(xlf);
    
    % Shift sample
    shift_samp = 2*pi * (state.pos - sample_pos) ./ (sample_scale * params.img_support_sz);
    xlf = shift_sample(xlf, shift_samp, params.kx, params.ky);
    
    % Init the projection matrix
    state.projection_matrix = init_projection_matrix(xl, params.sample_dim, params);
    
    % Project sample
    xlf_proj = project_sample(xlf, state.projection_matrix);
    
    clear xlw
    
elseif params.learning_rate > 0
    
if seq.frame == 2
    if state.flag_PE
        [kf_state.feature,kf_state.patch] = extract_template_features(im_rgb,round(state.pos+state.dist_PE([2,1]))-1,kf_params.template_features,state.target_sz,seq.init_sz(:)',kf_params.use_gpu);
    else
        [kf_state.feature,kf_state.patch] = extract_template_features(im_rgb,state.pos,kf_params.template_features,state.target_sz,seq.init_sz(:)',kf_params.use_gpu);
    end
    for x = 1:length(kf_state.feature)
        res = xcorr(kf_state.feature{x}(:),kf_state.template{x}(:));
        res = gather(res);
        kf_params.max_score_init(x) = max(res);
    end
end

    if ~params.use_detection_sample
        % Extract image region for training sample
        state.sample_pos = round(state.pos);
        sample_scale = state.currentScaleFactor;
        xl = extract_features(im, state.sample_pos, state.currentScaleFactor, params.features, params.global_fparams, params.feature_extract_info);
        % Project sample
        xl_proj = project_sample(xl, state.projection_matrix);
        % Do windowing of features
        xl_proj = cellfun(@(feat_map, cos_window) bsxfun(@times, feat_map, cos_window), xl_proj, params.cos_window, 'uniformoutput', false);
        % Compute the fourier series
        xlf1_proj = cellfun(@cfft2, xl_proj, 'uniformoutput', false);
        % Interpolate features to the continuous domain
        xlf1_proj = interpolate_dft(xlf1_proj, params.interp1_fs, params.interp2_fs);
        % New sample to be added
        xlf_proj = compact_fourier_coeff(xlf1_proj);
    else
        % Use the sample that was used for detection
        sample_scale = state.sample_scale(state.scale_ind);
        xlf_proj = cellfun(@(xf) xf(:,1:(size(xf,2)+1)/2,:,state.scale_ind), state.xtf_proj, 'uniformoutput', false);    
    end
    
    % Shift the sample so that the target is centered
    
    shift_samp = 2*pi * (state.pos - state.sample_pos) ./ (sample_scale * params.img_support_sz);
    xlf_proj = shift_sample(xlf_proj, shift_samp, params.kx, params.ky);
end

% The permuted sample is only needed for the CPU implementation
if ~params.use_gpu
    xlf_proj_perm = cellfun(@(xf) permute(xf, [4 3 1 2]), xlf_proj, 'uniformoutput', false);
end
if ~kf_state.flagOCC
    if params.use_sample_merge
        % Update the samplesf to include the new sample. The distance
        % matrix, kernel matrix and prior weight are also updated
        if params.use_gpu
            [merged_sample, new_sample, merged_sample_id, new_sample_id, state.distance_matrix, state.gram_matrix, state.prior_weights] = ...
                update_sample_space_model_gpu(state.samplesf, xlf_proj, state.distance_matrix, state.gram_matrix, state.prior_weights,...
                state.num_training_samples,params);
            
        else
            [merged_sample, new_sample, merged_sample_id, new_sample_id, state.distance_matrix, state.gram_matrix, state.prior_weights] = ...
                update_sample_space_model(state.samplesf, xlf_proj_perm, state.distance_matrix, state.gram_matrix, state.prior_weights,...
                state.num_training_samples,params);
        end
        
        if state.num_training_samples < params.nSamples
            state.num_training_samples = state.num_training_samples + 1;
            
        end
    elseif ~params.use_sample_merge
        % Do the traditional adding of a training sample and weight update
        % of C-COT
        [prior_weights, replace_ind] = update_prior_weights(state.prior_weights, gather(state.sample_weights), state.latest_ind, seq.frame, params);
        state.latest_ind = replace_ind;
        
        merged_sample_id = 0;
        new_sample_id = replace_ind;
        if params.use_gpu
            new_sample = xlf_proj;
        else
            new_sample = xlf_proj_perm;
        end
    end
end

if (seq.frame > 1 && params.learning_rate > 0 || seq.frame == 1 && ~params.update_projection_matrix) && ~kf_state.flagOCC
    
    % Insert the new training sample
    for k = 1:params.num_feature_blocks
        if params.use_gpu
            if merged_sample_id > 0
                state.samplesf{k}(:,:,:,merged_sample_id) = merged_sample{k};
            end
            if new_sample_id > 0
                state.samplesf{k}(:,:,:,new_sample_id) = new_sample{k};
            end
        else
            if merged_sample_id > 0
                state.samplesf{k}(merged_sample_id,:,:,:) = merged_sample{k};
            end
            if new_sample_id > 0
                state.samplesf{k}(new_sample_id,:,:,:) = new_sample{k};
            end
        end
    end
end

state.sample_weights = cast(state.prior_weights, 'like', params.data_type);

train_tracker = (seq.frame < params.skip_after_frame) || (state.frames_since_last_train >= params.train_gap);
if ~kf_state.flagOCC
    if train_tracker
        % Used for preconditioning
        new_sample_energy = cellfun(@(xlf) abs(xlf .* conj(xlf)), xlf_proj, 'uniformoutput', false);
        
        if seq.frame == 1
            % Initialize stuff for the filter learning
            
            % Initialize Conjugate Gradient parameters
            state.sample_energy = new_sample_energy;
            state.CG_state = [];
            
            if params.update_projection_matrix
                % Number of CG iterations per GN iteration
                params.init_CG_opts.maxit = ceil(params.init_CG_iter / params.init_GN_iter);
                
                state.hf = cell(2,1,params.num_feature_blocks);
                state.proj_energy = cellfun(@(P, yf) 2*sum(abs(yf(:)).^2) / sum(params.feature_dim) * ones(size(P), 'like', params.data_type), state.projection_matrix, params.yf, 'uniformoutput', false);
            else
                params.CG_opts.maxit = params.init_CG_iter; % Number of initial iterations if projection matrix is not updated
                
                state.hf = cell(1,1,params.num_feature_blocks);
            end
            
            % Initialize the filter with zeros
            for k = 1:params.num_feature_blocks
                state.hf{1,1,k} = zeros([params.filter_sz(k,1) (params.filter_sz(k,2)+1)/2 params.sample_dim(k)], 'like', params.data_type_complex);
            end
        else
            params.CG_opts.maxit = params.CG_iter;
            
            % Update the approximate average sample energy using the learning
            % rate. This is only used to construct the preconditioner.
            state.sample_energy = cellfun(@(se, nse) (1 - params.learning_rate) * se + params.learning_rate * nse, state.sample_energy, new_sample_energy, 'uniformoutput', false);
        end
        
        % Do training
        if seq.frame == 1 && params.update_projection_matrix
            
            % Initial Gauss-Newton optimization of the filter and
            % projection matrix.
            if params.use_gpu
                [state.hf, state.projection_matrix, ~] = train_joint_gpu(state.hf, state.projection_matrix, xlf, params.yf, params.reg_filter, state.sample_energy, params.reg_energy, state.proj_energy, params, params.init_CG_opts);
            else
                [state.hf, state.projection_matrix, ~] = train_joint(state.hf, state.projection_matrix, xlf, params.yf, params.reg_filter, state.sample_energy, params.reg_energy, state.proj_energy, params, params.init_CG_opts);
            end
            state.hf_init = state.hf;
            % Re-project and insert training sample
            xlf_proj = project_sample(xlf, state.projection_matrix);
            for k = 1:params.num_feature_blocks
                if params.use_gpu
                    state.samplesf{k}(:,:,:,1) = xlf_proj{k};
                else
                    state.samplesf{k}(1,:,:,:) = permute(xlf_proj{k}, [4 3 1 2]);
                end
            end
            
            % Update the gram matrix since the sample has changed
            if strcmp(params.distance_matrix_update_type, 'exact')
                % Find the norm of the reprojected sample
                state.new_train_sample_norm =  0;
                
                for k = 1:params.num_feature_blocks
                    state.new_train_sample_norm = state.new_train_sample_norm + real(gather(2*(xlf_proj{k}(:)' * xlf_proj{k}(:))));% - reshape(xlf_proj{k}(:,end,:,:), [], 1, 1)' * reshape(xlf_proj{k}(:,end,:,:), [], 1, 1));
                end
                
                state.gram_matrix(1,1) = state.new_train_sample_norm;
            end
        else
            % Do Conjugate gradient optimization of the filter
            if params.use_gpu
                [state.hf, ~, state.CG_state] = train_filter_gpu(state.hf, state.samplesf, params.yf, params.reg_filter, state.sample_weights, state.sample_energy, params.reg_energy, params, params.CG_opts, state.CG_state);
            else
                [state.hf, ~, state.CG_state] = train_filter(state.hf, state.samplesf, params.yf, params.reg_filter, state.sample_weights, state.sample_energy, params.reg_energy, params, params.CG_opts, state.CG_state);
            end
        end
        
        % Reconstruct the full Fourier series
        state.hf_full = full_fourier_coeff(state.hf);
        
        state.frames_since_last_train = 0;
    else
        state.frames_since_last_train = state.frames_since_last_train+1;
        
    end
end
