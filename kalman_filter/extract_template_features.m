function [features, template]= extract_template_features(im,sample_pos,template_features,target_sz,target_sz_init,use_gpu)
if ~exist('target_sz_init')
    template = sample_patch(im,sample_pos,target_sz,target_sz);
else
    template = sample_patch(im,sample_pos,target_sz,target_sz_init);
end
index = 1;
features = cell(length(template_features),1);
for i = 1:length(template_features)
    if isequal(template_features{i}.getFeature,@get_fhog)
        params.cell_size = 4;
        params.compressed_dim = 10;
        params.nOrients = 9;
        params.nDim = 31;
        hog_params.data_type = zeros(1, 'single', 'gpuArray');
        features{index} = template_features{i}.getFeature(template,params,hog_params);
        index = index + 1;
    end
    
    if isequal(template_features{i}.getFeature,@get_cnn_layers1)
        cnn_params.use_gpu = use_gpu;
        cnn_features = template_features{i}.getFeature(template,template_features{i}.fparams,cnn_params);
        for ii = 1:length(template_features{1}.fparams.output_layer)
            features{index} = cnn_features{ii};
            index = index + 1;
        end
    end
    
    if isequal(template_features{i}.getFeature,@get_colorspace)
        cn_params.use_gpu = use_gpu;
        features{index} = template_features{i}.getFeature(template,template_features{i}.fparams,cn_params);
        index = index + 1;
    end
    
    if isequal(template_features{i}.getFeature,@get_table_feature)
        table_params.use_gpu = use_gpu;
        features{index} = template_features{i}.getFeature(template,template_features{i}.fparams,table_params);
        index = index + 1;
    end
    
end