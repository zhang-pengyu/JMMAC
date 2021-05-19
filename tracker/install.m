% Compile libraries and download network

[home_dir, name, ext] = fileparts(mfilename('fullpath'));

warning('ON', 'ECO:install')

%% mtimesx
disp('-----------------------------------------------------');
disp('------------------compiling mtimesx------------------');
disp('-----------------------------------------------------');

if exist('external_libs/mtimesx', 'dir') == 7
    cd external_libs/mtimesx
    mtimesx_build;
    cd(home_dir)
else
    error('ECO:install', 'Mtimesx not found.')
end

%% PDollar toolbox
disp('-----------------------------------------------------');
disp('------------------compiling pdollar------------------');
disp('-----------------------------------------------------');
if exist('external_libs/pdollar_toolbox/external', 'dir') == 7
    cd external_libs/pdollar_toolbox/external
    toolboxCompile;
    cd(home_dir)
else
    warning('ECO:install', 'PDollars toolbox not found. Clone this submodule if you want to use HOG features. Skipping for now.')
end

%% matconvnet
disp('--------------------------------------------------------');
disp('------------------compiling matconvnet------------------');
disp('--------------------------------------------------------');
if exist('external_libs/matconvnet/matlab', 'dir') == 7
    cd external_libs/matconvnet/matlab
    try
        disp('Trying to compile MatConvNet with GPU support')
        vl_compilenn('enableGpu', true)
    catch err
        warning('ECO:install', 'Could not compile MatConvNet with GPU support. Compiling for only CPU instead.\nVisit http://www.vlfeat.org/matconvnet/install/ for instructions of how to compile MatConvNet.\nNote: remember to move the mex-files after re-compiling.');
        vl_compilenn;
    end
    status = movefile('mex/vl_*.mex*');
    cd(home_dir)
    
    %% donwload network
    disp('-------------------------------------------------------');
    disp('------------------downloading VGG network------------------');
    disp('-------------------------------------------------------');
    cd feature_extraction
    mkdir networks
    cd networks
    if ~(exist('imagenet-vgg-m-2048.mat', 'file') == 2)
        disp('Downloading the network "imagenet-vgg-m-2048.mat" from "http://www.vlfeat.org/matconvnet/models/imagenet-vgg-m-2048.mat"...')
        websave('imagenet-vgg-m-2048.mat','http://www.vlfeat.org/matconvnet/models/imagenet-vgg-m-2048.mat');
        disp('Done!')
    end
    if ~(exist('imagenet-vgg-verydeep-19.mat', 'file') == 2)
        disp('Downloading the network "imagenet-vgg-verydeep-19.mat" from "http://www.vlfeat.org/matconvnet/models/imagenet-vgg-verydeep-19.mat"...')
        websave('imagenet-vgg-verydeep-19.mat','http://www.vlfeat.org/matconvnet/models/imagenet-vgg-verydeep-19.mat');
        disp('Done!')
    end
    cd(home_dir)
else
    warning('ECO:install', 'Matconvnet not found. Clone this submodule if you want to use CNN features. Skipping for now.')
end

disp('-------------------------------------------------');
disp('------------------downloading yolo Network------------------');
disp('-------------------------------------------------');

cd external_libs/yolo/darknet/cfg

if ~(exist('yolov2.weights', 'file') == 2)
    disp('Downloading the network "yolov2" from "https://pjreddie.com/media/files/yolov2.weights"...')
    websave('yolov2.weights', 'https://pjreddie.com/media/files/yolov2.weights');
    disp('Done!')
end


cd(home_dir)


disp('-------------------------------------------------');
disp('------------------compiling yolo------------------');
disp('-------------------------------------------------');

cd external_libs/yolo
mex -I./darknet/include/ -I./darknet/src CFLAGS='-Wall -Wfatal-errors -Wno-unused-result -fPIC' -L. -lyolo -L/usr/local/cuda/lib64 -lcudart -lcublas -lcurand yolomex.c
cd(home_dir)
