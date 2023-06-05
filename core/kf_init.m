function [state, params] = kf_init(t_state,params,im_rgb,seq)

params.template_features{1}.fparams.net = load_cnn(params.template_cnn_params,seq.init_sz(:)');
if params.use_gpu
	params.template_features{1}.fparams.net = vl_simplenn_move(params.template_features{1}.fparams.net, 'gpu');
end
if t_state.flag_PE
    [state.template,state.init_patch] = extract_template_features(im_rgb,t_state.pos_rgb,params.template_features,seq.init_sz(:)',seq.init_sz(:)',params.use_gpu);
else
    [state.template,state.init_patch] = extract_template_features(im_rgb,seq.init_pos(:)',params.template_features,seq.init_sz(:)',seq.init_sz(:)',params.use_gpu);
end
state.d_total = [0,0];
state.flagOCC = 0;
