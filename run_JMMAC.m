function results = run_JMMAC(seq, res_path, bSaveImage)
%% an offical MATLAB implementation of tracker 'Joint Modeling Motion and Appearance Cues (JMMAC) for Robust RGB-T Tracking'.
%% Our tracker has been tested in Ubuntu 16.04 with Nvidia GTX Titan X GPU.


setpath();
vl_setupnn();
%% setting for vot-rgbt dataset.
seq.format = 'rgbt';
%% visualization parameter
visualize = 0;
%% gpu selection, if use CPU, set use_gpu = false.
use_gpu = true; %false true
gpu_id = 0;
%%
frame_interval = 3;
%% parameter setting
t_params = t_parameter_setting();
det_params = det_parameter_setting();
kf_params = kf_parameter_setting();
[t_params,det_params,kf_params] = parameter_setting(t_params,det_params,kf_params,use_gpu,gpu_id);

seq.frame = 1;
seq.time = 0;
[seq, im_rgb, im_t] = get_sequence_info(seq);

%% first frame initialization
[t_state,t_params] = t_init(t_params,im_t,seq);
t_state = judge_pe(t_state,im_rgb,im_t);
[det_state,det_params] = det_init(t_state,t_params,det_params,im_rgb,seq);
[kf_state,kf_params] = kf_init(t_state, kf_params,im_rgb,seq);
%% first frame updating
[t_state,kf_state,t_params,kf_params] = t_updating(t_state,kf_state,t_params,kf_params,im_rgb,im_t,seq);

[seq] = get_tracking_results(t_state, seq);

if visualize
    seq = visualization_rgbt(t_state,det_state,kf_state,im_t,seq);
end

im_record_rgb = cell(frame_interval,1);
im_record_t = cell(frame_interval,1);
pos_record = cell(frame_interval,1);
target_sz_record = cell(frame_interval,1);

%% record previous frames and postions
[im_record_rgb,im_record_t,pos_record,target_sz_record] = record_frame(im_record_rgb,im_record_t,pos_record,target_sz_record,im_rgb,im_t,t_state.pos,t_state.target_sz);

%% main loop
while true
    
    det_state = det_reset(det_state);
    [seq, im_rgb, im_t] = get_sequence_frame(seq);
    [flag, im_rgb, im_t] = check_image(im_rgb,im_t);
    if flag
        break;
    end
    tic();    
    
    %% tracking
    flagCM = judge_cm(im_rgb, im_t, im_record_rgb{1}, im_record_t{1});
    [t_state,kf_state] = t_tracking(t_state,kf_state,t_params, im_t, im_record_t,pos_record,target_sz_record, flagCM, seq);
    [t_state,kf_state,kf_params] = judge_occ(t_state,kf_state,t_params,kf_params,im_rgb,seq);
    [t_state] = pos_updating(t_state,kf_state,t_params);
    [t_state,kf_state] = kf_updating(t_state,kf_state,t_params,seq);
    [t_state,det_state,t_params] = process_det(t_state,kf_state,det_state,t_params,det_params,im_rgb);
    [t_state, t_params,det_params] = sz_updating(t_state,det_state,t_params,det_params);
    
    %% updating
    [t_state,kf_state,t_params,kf_params] = t_updating(t_state,kf_state,t_params,kf_params,im_rgb,im_t,seq);
    seq.time = seq.time + toc();
    [seq] = get_tracking_results(t_state, seq);
    
    %% visualization
    if visualize
        seq = visualization_rgbt(t_state,det_state,kf_state,im_t,seq);
    end
    [ im_record_rgb,im_record_t,pos_record,target_sz_record ] = record_frame(im_record_rgb,im_record_t,pos_record,target_sz_record,im_rgb,im_t,t_state.pos,t_state.target_sz);
    
end
[seq, results] = get_sequence_results(seq);
disp(['fps: ' num2str(results.fps)])
