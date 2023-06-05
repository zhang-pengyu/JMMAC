function state = t_pos_updating(state,params)
    % update position
    state.old_pos = state.pos;
    state.pos = state.sample_pos + state.translation_vec;
    
    % Compute the translation vector in pixel-coordinates and round
    % to the closest integer pixel.
    
    
    if params.clamp_position
        state.pos = max([1 1], min([size(im,1) size(im,2)], state.pos));
    end
    
    % Do scale tracking with the scale filter
    if params.nScales > 0 && params.use_scale_filter
        state.scale_change_factor = scale_filter_track(im, pos, base_target_sz, currentScaleFactor, scale_filter, params);
    end
    
    % Update the scale
    state.currentScaleFactor = state.currentScaleFactor * state.scale_change_factor;
    
    % Adjust to make sure we are not to large or to small
    if state.currentScaleFactor < params.min_scale_factor
        state.currentScaleFactor = params.min_scale_factor;
    elseif state.currentScaleFactor > params.max_scale_factor
        state.currentScaleFactor = params.max_scale_factor;
    end
end

