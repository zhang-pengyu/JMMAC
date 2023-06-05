function params = det_parameter_setting()

%% bbreg
params.bbreg = true;
params.bbreg_nSamples=1000;
params.scale_factor = 1.05;
params.mdnet_file='imagenet-vgg-m-2048.mat';
% cropping policy
params.input_size = 107;
params.crop_mode = 'wrap';
params.crop_padding = 16;
params.batchSize_test = 256;
%% SSD
folder = fileparts(mfilename('fullpath'));
folder = folder(1:end-4);
params.SSD_file= [folder,'external_libs/matconvnet/contrib/mcnSSD/models/ssd-mcn-pascal-vggvd-300.mat'];
params.wrapper = 'autonn' ;
params.confidence=0.615;
params.last_area=0;
params.pr_conf=100;
params.pr_area=5;
params.pr_center_occ=0;
params.pr_center_no_occ=1.0;

params.scale_sub=0.9;
params.scale_sub_all=1.2;
params.scale_=1.5;
%% random seed
params.s1=1;
params.s2=10;
params.s3=15;
