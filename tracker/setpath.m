function setup_paths()

% Add the neccesary paths

[pathstr, name, ext] = fileparts(mfilename('fullpath'));

% Tracker implementation
addpath(genpath([pathstr '/implementation/']));

% Runfiles
% addpath([pathstr '/runfiles/']);

% Utilities
addpath([pathstr '/utils/']);

% The feature extraction
addpath(genpath([pathstr '/feature_extraction/']));


% Matconvnet
addpath(genpath([pathstr '/external_libs/yolo/']));
addpath([pathstr '/external_libs/matconvnet/matlab/mex/']);
addpath([pathstr '/external_libs/matconvnet/matlab']);
addpath([pathstr '/external_libs/matconvnet/matlab/simplenn']);
addpath(genpath([pathstr '/external_libs/matconvnet/contrib/mcnSSD/matlab/mex/']));
addpath(genpath([pathstr '/external_libs/matconvnet/contrib/mcnExtraLayers/']));
addpath(genpath([pathstr '/external_libs/matconvnet/contrib/autonn/']));
addpath(genpath([pathstr '/external_libs/matconvnet/contrib']));
addpath(genpath([pathstr '/external_libs/matconvnet/contrib/mcnSSD/matlab/mex']));
addpath(genpath([pathstr '/camera_motion/']));
addpath(genpath([pathstr '/kalman_filter/']));
addpath(genpath([pathstr '/image_fusion/']));

% PDollar toolbox
addpath(genpath([pathstr '/external_libs/pdollar_toolbox/channels']));

% Mtimesx
addpath([pathstr '/external_libs/mtimesx/']);

% mexResize
addpath([pathstr '/external_libs/mexResize/']);

addpath(genpath([pathstr '/core/']));
addpath(genpath([pathstr '/external_libs/DDIS-master/']));