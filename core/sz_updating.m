function [t_state, t_params,det_params] = sz_updating(t_state,det_state,t_params,det_params)

t_state.currentScaleFactor = t_state.currentScaleFactor * t_state.scale_change_factor;
if t_state.currentScaleFactor < t_params.min_scale_factor
    t_state.currentScaleFactor = t_params.min_scale_factor;
elseif t_state.currentScaleFactor > t_params.max_scale_factor
    t_state.currentScaleFactor = t_params.max_scale_factor;
end

t_state.target_sz = t_params.base_target_sz * t_state.currentScaleFactor;
if det_state.haveObj
    t_state.target_sz=[det_state.obj_h, det_state.obj_w];
    t_params.base_target_sz = t_state.target_sz / t_state.currentScaleFactor;
    det_params.last_area=t_state.target_sz(1)*t_state.target_sz(2);
end
