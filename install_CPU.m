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
        disp('Trying to compile MatConvNet with CPU support')
        vl_compilenn();
    catch err
        warning('ECO:install', 'Could not compile MatConvNet with GPU support. Compiling for only CPU instead.\nVisit http://www.vlfeat.org/matconvnet/install/ for instructions of how to compile MatConvNet.\nNote: remember to move the mex-files after re-compiling.');
        vl_compilenn;
    end
    status = movefile('mex/vl_*.mex*');
    cd(home_dir)
    
%% donwload network
disp('-------------------------------------------------------');
disp('------------------downloading network------------------');
disp('-------------------------------------------------------');
    cd feature_extraction
    mkdir networks
    cd networks
    if ~(exist('imagenet-vgg-m-2048.mat', 'file') == 2)
        disp('Downloading the network "imagenet-vgg-m-2048.mat" from "http://www.vlfeat.org/matconvnet/models/imagenet-vgg-m-2048.mat"...')
        urlwrite('http://www.vlfeat.org/matconvnet/models/imagenet-vgg-m-2048.mat', 'imagenet-vgg-m-2048.mat')
        disp('Done!')
    end
    cd(home_dir)
else
    warning('ECO:install', 'Matconvnet not found. Clone this submodule if you want to use CNN features. Skipping for now.')
end

%% mcnSSD
disp('-------------------------------------------------');
disp('------------------compiling SSD------------------');
disp('-------------------------------------------------');
cd external_libs/matconvnet/contrib/mcnSSD/models
if ~(exist('ssd-mcn-pascal-vggvd-300.mat', 'file') == 2)
        disp('Downloading the network "ssd-mcn-pascal-vggvd-300.mat" from "http://www.robots.ox.ac.uk/~albanie/models/ssd/ssd-mcn-pascal-vggvd-300.mat"...')
        urlwrite('http://www.robots.ox.ac.uk/~albanie/models/ssd/ssd-mcn-pascal-vggvd-300.mat', 'ssd-mcn-pascal-vggvd-300.mat')
        disp('Done!')
end
cd(home_dir)
cd external_libs/matconvnet/contrib

vl_contrib('install', 'mcnSSD') ;
vl_contrib('compile', 'mcnSSD') ;
vl_contrib('setup', 'mcnSSD') ;

cd(home_dir)
