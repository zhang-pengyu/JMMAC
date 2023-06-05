function [t_state] = pos_updating(t_state,kf_state,t_params)


t_state.pos = t_state.sample_pos + t_state.translation_vec;
t_state.scale_change_factor = t_params.scaleFactors(t_state.scale_ind);

