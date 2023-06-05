function params = kf_parameter_setting()

params.thr_feature_low_1 = 0.11;
params.thr_feature_low_2 = 0.13;
params.thr_feature_low_3 = 0.31;
params.thr_feature_low_4 = 0.13;

params.thr_feature_high_1 = 0.65;
params.thr_feature_high_2 = 0.50;
params.thr_feature_high_3 = 0.31;
params.thr_feature_high_4 = 1224;

params.template_cnn_params.nn_name = 'imagenet-vgg-m-2048.mat'; 
params.template_cnn_params.output_layer = 3;
params.template_cnn_params.downsample_factor = 1;
params.template_cnn_params.compressed_dim = 64;
params.template_cnn_params.input_size_mode = 'adaptive';
params.template_cnn_params.input_size_scale = 1;
grayscale_params.colorspace='gray';
grayscale_params.cell_size = 1;
hog_params.cell_size = 4;
hog_params.compressed_dim = 10;

params.template_features = {
    struct('getFeature',@get_cnn_layers1, 'fparams',params.template_cnn_params),...
    struct('getFeature',@get_colorspace, 'fparams',grayscale_params),...
    struct('getFeature',@get_fhog,'fparams',hog_params),...
};