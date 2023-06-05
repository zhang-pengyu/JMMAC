function [ feat ] = mdnet_features_convX(net, img, boxes, opts)
% MDNET_FEATURES_CONVX
% Extract CNN features from bounding box regions of an input image.
%
% Hyeonseob Nam, 2015
% 
n = size(boxes,1);
if(size(img,3)==1), img = cat(3,img,img,img); end
ims = mdnet_extract_regions(img, boxes, opts);
nBatches = ceil(n/opts.batchSize_test);

for i=1:nBatches
%     fprintf('extract batch %d/%d...\n',i,nBatches);
    if size(ims,4)==1
%         batch = ims(:,:,:,opts.batchSize_test*(i-1)+1:min(end,opts.batchSize_test*i));
        batch = ims(:,:,:,1);
    else
        batch = ims(:,:,:,opts.batchSize_test*(i-1)+1:min(end,opts.batchSize_test*i));
    end
    if(opts.use_gpu)
        batch = gpuArray(batch);
    end
%     if existsOnGPU(net.layers{1}.weights{1})
%         disp('net is on gpu');
%     else
%         disp('net is not on gpu');
%     end
    res = vl_simplenn(net, batch, [], [], ...
        'mode', 'normal', ...
        'conserveMemory', true, ...
        'sync', true) ;
%     res = vl_simplenn(net, batch, [], [], ...
%     'disableDropout', true, ...
%     'conserveMemory', true, ...
%     'sync', true) ;
    
    f = gather(res(end).x) ;
    if ~exist('feat','var')
        feat = zeros(size(f,1),size(f,2),size(f,3),n,'single');
    end
    feat(:,:,:,opts.batchSize_test*(i-1)+1:min(end,opts.batchSize_test*i)) = f;
end