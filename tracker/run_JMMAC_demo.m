%% an offical MATLAB implementation of tracker 'Joint Modeling Motion and Appearance Cues (JMMAC) for Robust RGB-T Tracking'.
%% Our tracker has been tested in Ubuntu 18.04 with Nvidia GTX-2080ti GPU.

warning('off');
setpath();
vl_setupnn();

%% The flag for testing each modules set flag = 1 to activate 
enable_CM = 1;
enable_OCC = 1;
enable_DET = 1;
enable_MF = 1;
%% Sequence setting
RGB_path = './demo/afterrain/visible/';
T_path = './demo/afterrain/infrared/'; 

RGB_dir = dir([RGB_path,'*.jpg']);
T_dir = dir([T_path,'*.jpg']);

seq.init_rect = importdata('./demo/afterrain/init.txt');

seq.image_files = 1;
seq.init_sz = [seq.init_rect(1,4), seq.init_rect(1,3)];
seq.init_pos = [seq.init_rect(1,2), seq.init_rect(1,1)] + (seq.init_sz - 1)/2;
seq.num_frames = numel(RGB_dir);
seq.rect_position = zeros(seq.num_frames, 4);
im_t = imread([T_path,T_dir(1).name]);
im_rgb = imread([RGB_path,RGB_dir(1).name]);
seq.targetLoc = round(seq.init_rect(1,:));
%% visualization parameter
visualize = 1;
%% gpu selection, if use CPU, set use_gpu = false.
use_gpu = true; %false true
gpu_id = 1;
%%
frame_interval = 3;
output_sz = [200,200];
%% parameter setting
t_params = t_parameter_setting();
rgb_params = rgb_parameter_setting();
if enable_DET
    det_params = det_parameter_setting();
else
    det_params = [];
end
if enable_OCC
    kf_params = kf_parameter_setting();
else
    kf_params = [];
end


[rgb_params, t_params,det_params,kf_params] = parameter_setting(rgb_params,t_params,det_params,kf_params,use_gpu,gpu_id);

seq.frame = 1;
seq.time = 0;

%% first frame initialization
[t_state,t_params] = t_init(t_params,im_t,seq);
[rgb_state,rgb_params] = rgb_init(rgb_params,im_rgb,seq);
t_state = judge_pe(t_state,im_rgb,im_t);
if enable_DET
    [det_state,det_params] = det_init_yolo(t_state,t_params,det_params,im_rgb,seq);
else
    det_state.flagDET = 0;
end

if enable_OCC
    [kf_state,kf_params] = kf_init(t_state, kf_params,im_rgb,seq);
else
    kf_state.flagOCC = 0;
    kf_state.d_total = [0,0];
end
if enable_MF
    MFNet_path = './MFNet/MFNet_RGBT234.mat';
    FusionNet = FusionNet_GL_init(use_gpu,MFNet_path);
    VggNet = load_cnn_train(output_sz,use_gpu);
end
%% first frame updating

[t_state,t_params] = t_updating(t_state,kf_state,t_params,im_t,seq);
[rgb_state,rgb_params] = rgb_updating(rgb_state,kf_state,rgb_params,im_rgb,seq);

[seq] = get_tracking_results(t_state, seq);

if visualize
    seq = visualization_rgbt(t_state,det_state,kf_state,im_rgb,seq);
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
    seq.frame = seq.frame + 1;
    if seq.frame > seq.num_frames
        break;
    end
    im_rgb = imread([RGB_path,RGB_dir(seq.frame).name]);
    im_t = imread([T_path,T_dir(seq.frame).name]);
    
    tic();
    %% tracking
    if enable_CM
        flagCM = judge_cm(im_rgb, im_t, im_record_rgb{1}, im_record_t{1});
    else
        flagCM = 0;
    end
    [rgb_state,t_state,kf_state] = t_tracking(rgb_state,t_state,kf_state,t_params, im_t, im_record_t,pos_record,target_sz_record, flagCM, seq);
    rgb_state = rgb_tracking(rgb_state, rgb_params, im_rgb);
    if enable_MF
        [rgb_state, t_state] = rgbt_fusion(rgb_state,t_state,rgb_params,t_params, im_rgb,im_t,FusionNet,VggNet);
    else
        [rgb_state, t_state] = rgbt_fusion(rgb_state,t_state,rgb_params,t_params, im_rgb,im_t);
    end
        [rgb_state, t_state] = pos_updating(rgb_state,t_state,t_params);
    if enable_OCC
        if seq.frame < 4
            kf_state.flag_simi = find_similar_image(im_t, im_record_t{seq.frame-1});
        else
            kf_state.flag_simi = find_similar_image(im_t, im_record_t{3});
        end
        [t_state,kf_state,kf_params] = judge_occ(t_state,kf_state,det_state,t_params,kf_params,im_rgb,seq);
        [rgb_state,t_state,kf_state] = kf_updating(rgb_state,t_state,kf_state,rgb_params,t_params,seq);
    end
    if enable_DET
        [rgb_state,t_state,det_state,rgb_params,t_params] = process_det_yolo(rgb_state,t_state,kf_state,det_state,rgb_params,t_params,det_params,im_rgb);
    end
    [rgb_state, t_state, rgb_params, t_params] = sz_updating(rgb_state,t_state,det_state,rgb_params,t_params);
    %% updating
    [t_state,t_params] = t_updating(t_state,kf_state,t_params,im_t,seq);
    [rgb_state,rgb_params] = rgb_updating(rgb_state,kf_state,rgb_params,im_rgb,seq);
    %     toc();
    seq.time = seq.time + toc();
    [seq] = get_tracking_results(t_state, seq);
    %% visualization
    if visualize
        seq = visualization_rgbt(t_state,det_state,kf_state,im_rgb,seq);
    end
    [ im_record_rgb,im_record_t,pos_record,target_sz_record ] = record_frame(im_record_rgb,im_record_t,pos_record,target_sz_record,im_rgb,im_t,t_state.pos,t_state.target_sz);
    
end
disp(['fps: ' num2str(seq.num_frames / seq.time)])
