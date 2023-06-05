function [seq] = get_tracking_results(t_state, seq)
%save position and calculate FPS

tracking_result.center_pos = double(t_state.pos);
tracking_result.target_size = double(t_state.target_sz);
seq = report_tracking_result(seq, tracking_result);
end