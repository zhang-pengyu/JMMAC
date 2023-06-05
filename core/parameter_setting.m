function [ t_params,det_params,kf_params ] = parameter_setting(t_params,det_params,kf_params,use_gpu,gpu_id )

t_params.use_gpu = use_gpu;
det_params.use_gpu = use_gpu;
kf_params.use_gpu = use_gpu;

t_params.gpu_id = gpu_id;
det_params.gpu_id = gpu_id;
kf_params.gpu_id = gpu_id;

end

