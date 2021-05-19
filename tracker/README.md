# JMMAC

    This is an offical MATLAB implementation of tracker 'Joint Modeling Motion and Appearance Cues~(JMMAC) for Robust RGB-T Tracking' submitted to VOT-RGBT2020 challenge.

## Introduction

    In this study, we propose a novel RGB-T tracking framework by jointly modeling both appearance and motion cues. First, to obtain a robust appearance model, we develop a novel late fusion method to infer the fusion weight maps of both RGB and thermal (T) modalities. The fusion weights are determined by using offline-trained global and local Multimodal Fusion Networks (MFNet), and then adopted to linearly combine the response maps of RGB and T modalities obtained from ECOs. Second, when the appearance cue is unreliable, we comprehensively take motion cues, i.e., camera motions, into account to make the tracker robust. The camera motion is inferred based on the key-point-based image registration technique. Finally, we employ YOLOv2 to refine the bounding box.
   
## Dependence
 
    CUDA 10.0 
    CuDNN 7.4.1
    Matconvnet 1.0-beta25~(www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta25.tar.gz)
    MATLAB 2015b~(Other version of MATLAB may get different results.)
    gcc 4.8
    g++ 4.8
    PDollar Toolbox~(https://github.com/pdollar/toolbox)

##  Operation System
   
    Our tracker is run on Ubuntu 18.04 LTS with Intel i9-9900k @3.6GHz and Nvidia GTX-2080ti GPU. Other OS and GPU may get different results. 
   
## Installation
        
    Set your tracker path in the file './external_libs/yolo/darknet/cfg/coco.data' to load the coco dataset.

    Start Matlab and navigate to the repository. 
    Run the install script:
    |>> install

    if you have no GPU, you can run our tracker with single CPU.
    Run the install_CPU script:
    |>> install_CPU

## Integration Into VOT
    
    First, you need to set 'MATLAB_ROOT' to your environment to let vot find your MATLAB execution.
    
    Since MATLAB needs compilation and there will be a one-time delay for GPU computing commands, please increase the time limitation of trax by 
    setting 'timeout' = 500 in file 'your_vot_path/tracker/trax.py'.

    To integrate the tracker into the Visual Object Tracking (VOT) challenge toolkit, check the 'VOT_integration' folder. 
    Copy the configuration file 'tracker.ini' to your tracker configuration file and set the path to the tracker reposetory inside it.

## Testing without GPU

    If you run the tracker without GPU, please set the flag 'use_gpu' to false in run_JMMAC_VOT.m. 
    Note that this may lead a performace fluctuation without using GPU.

## Reference 

@InProceedings{ECO,
Title = {ECO: Efficient Convolution Operators for Tracking},
Author = {Danelljan, Martin and Bhat, Goutam and Shahbaz Khan, Fahad and Felsberg, Michael},
Booktitle = {CVPR},
Year = {2017}
}

