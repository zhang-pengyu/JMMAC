function [t_state,kf_state] = kf_updating(t_state,kf_state,t_params,seq)
if seq.frame == 2
    Kalman_pos = t_state.pos;
    kf_state = Kalman_filter_tracking(seq.frame,Kalman_pos,kf_state);
else
    Kalman_pos = t_state.pos + kf_state.d_total([2,1]);
    kf_state = Kalman_filter_tracking(seq.frame,Kalman_pos,kf_state); 
end
% Kalman_pos
if kf_state.flagOCC
    t_state.pos = kf_state.loc -kf_state.d_total([2,1]);
    t_state.scale_change_factor = 1;
end

if t_params.clamp_position
    t_state.pos = max([1 1], min([size(im,1) size(im,2)], t_state.pos));
end
