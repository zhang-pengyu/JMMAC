function param = getDefaultParameters(mode)

initialLocation = 'Same as first detection';
initialEstimateError  = 1E5 * ones(1, 3);
motionNoise           = [25, 10, 1];
measurementNoise      = 25;
segmentationThreshold = 0.05;

if mode == 1
    param.motionModel           = 'ConstantAcceleration'; %'ConstantVelocity' 'ConstantAcceleration'
    param.initialLocation       = initialLocation;
    param.initialEstimateError  = initialEstimateError;
    param.motionNoise           = motionNoise;
    param.measurementNoise      = measurementNoise;
    param.segmentationThreshold = segmentationThreshold;
elseif mode == 2
    param.motionModel = 'ConstantVelocity';
    param.initialLocation       = initialLocation;
    param.measurementNoise      = measurementNoise;
    param.segmentationThreshold = segmentationThreshold;
    param.initialEstimateError = initialEstimateError(1:2);
    param.motionNoise          = motionNoise(1:2);
end