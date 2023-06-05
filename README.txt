# JMMAC

    This is an offical MATLAB implementation of tracker 'Joint Modeling Motion and Appearance Cues~(JMMAC) for Robust RGB-T Tracking' submitted to 
    VOT-RGBT2019 challenge.

## Introduction

    In this work, we have found that both motion and appearance cues are important for designing a robust RGB-T tracker. The motion cue includes two 
    components: camera motion and object motion. The camera motion is inferred based on the key-point-based image registration technique; and the 
    object motion is estimated based on the camera motion estimation and the Kalman filter method. The appearance cue is captured based on an improved
    ECO~\cite{ECO} model, where some complementary features (including deep and hand-crafted features) are selected for the RGB-T tracking task. 
    When the object suffers from heavy or full occlusion, a motion-guided tracking mechanism is used to avoid drifting, which makes the tracker be 
    dynamically switched between the tracking and prediction states. Our final tracker achieves 0.4826 of Expected Average Overlap~(EAO) in the 
    VOT-RGBT2019 challenge.

## Dependence
 
    CUDA 9.0 
    CuDNN 7.1.0
    Matconvnet 1.0-beta25~(www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta25.tar.gz)
    mcnSSD~(https://github.com/albanie/mcnSSD)
    MATLAB 2015b~(Other version of MATLAB may get different results.)
    gcc 4.8
    g++ 4.8
    PDollar Toolbox~(https://github.com/pdollar/toolbox)

##  Operation System
   
    Our tracker is run on Ubuntu 16.04 LTS with Intel i7-4790 @3.6GHz and Nvidia GTX TiTanX GPU. Other OS and GPU may get different results. 
   
## Installation

    Start Matlab and navigate to the repository. 
    Run the install script:
    |>> install

    if you have no GPU, you can run our tracker with single CPU.
    Run the install_CPU script:
    |>> install_CPU

## Integration Into VOT

    Since MATLAB needs compilation and there will be a one-time delay for GPU computing commands, please increase the time limitation of trax by 
    setting 'trax_timeout' = 3000 in file 'workspace_load.m'.

    To integrate the tracker into the Visual Object Tracking (VOT) challenge toolkit, check the 'VOT_integration' folder. 
    Copy the configuration file 'tracker_JMMAC.m' to your VOT workspace and set the path to the tracker reposetory inside it.

## Testing without GPU

    If you run the tracker without GPU, please copy the configuration file 'tracker_JMMAC_CPU.m' to VOT workspace. 
    Note that this may lead a performace fluctuation without using GPU.

## Reference 

@InProceedings{ECO,
Title = {ECO: Efficient Convolution Operators for Tracking},
Author = {Danelljan, Martin and Bhat, Goutam and Shahbaz Khan, Fahad and Felsberg, Michael},
Booktitle = {CVPR},
Year = {2017}
}

