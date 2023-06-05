function kf_state = Kalman_filter_tracking(frame,pos,kf_state)

if frame == 2
    initialLocation = pos;
    kf_state.model = getDefaultParameters(2);
    kf_state.model.kalmanFilter = configureKalmanFilter(kf_state.model.motionModel, ...
        initialLocation, kf_state.model.initialEstimateError, ...
        kf_state.model.motionNoise, kf_state.model.measurementNoise);
    kf_state.loc = correct(kf_state.model.kalmanFilter,pos);
% elseif flagCM==1&&sqrt(d(1)^2+d(2)^2)>8
%     clear KF_param;
%     initialLocation = pos;
%     KF_param = getDefaultParameters(2);
%     KF_param.kalmanFilter = configureKalmanFilter(KF_param.motionModel, ...
%         initialLocation, KF_param.initialEstimateError, ...
%         KF_param.motionNoise, KF_param.measurementNoise);
%     loc = correct(KF_param.kalmanFilter,pos);
% elseif flagCM==1
%         pos = pos+d;
%         predict(KF_param.kalmanFilter);
%         loc = correct(KF_param.kalmanFilter, pos);
else
    if kf_state.flagOCC == true
%         if flagCM==1
%             loc = predict(KF_param.kalmanFilter)+d;
%         else
            kf_state.loc = predict(kf_state.model.kalmanFilter);
%         end
    else
        predict(kf_state.model.kalmanFilter);
        kf_state.loc = correct(kf_state.model.kalmanFilter, pos);
    end
end