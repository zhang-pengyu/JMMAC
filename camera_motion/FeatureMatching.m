function [dist,isMotion]=FeatureMatching(I1,I2,pos,target_sz,mode)
if strcmp(mode,'sift')
    boxPolygon = pos2polygon(pos,target_sz);
    th1 = 1.7;
    I11=single(rgb2gray(I1));
    I22=single(rgb2gray(I2));
    [f11,d11] = vl_sift(I11);
    [f22,d22] = vl_sift(I22);
    [matches,score] = vl_ubcmatch(d11,d22,th1);
    [~,index] = sort(score);
    matches1 = matches(:,index);
    in_point = f11([1:2],matches1(1,:));
    out_point = f22([1:2],matches1(2,:));
    options.epsilon = 1e-6;
    options.P_inlier = 1-1e-4;
    options.sigma = 1;
    options.est_fun = @estimate_affine;
    options.man_fun = @error_affine;
    options.mode = 'MSAC';
    options.Ps = [];
    options.notify_iters = [];
    options.min_iters = 300;
    options.fix_seed = true;
    options.reestimate = true;
    options.stabilize = false;
    options.verbose = false;
    X = [in_point;out_point];
    [results, ~] = RANSAC(X, options);
    index = find(results.CS(:) == 1);
    in_point_select = in_point(:,index);
    out_point_select = out_point(:,index);
    tform = fitgeotrans(out_point_select' , in_point_select' ,'affine');
    newBoxPolygon = transformPointsForward(tform, boxPolygon);
    dist=axis_change(boxPolygon,newBoxPolygon);
    d=sqrt(dist(1,1)*dist(1,1)+dist(1,2)*dist(1,2));
    if d < 5
        isMotion=0;
    else
        isMotion=1;
    end
elseif strcmp(mode,'surf')
    %Find the SURF features
    boxPolygon = pos2polygon(pos,target_sz);
    I11=rgb2gray(I1);
    I22=rgb2gray(I2);
    points1 = detectSURFFeatures(I11);
    points2 = detectSURFFeatures(I22);
    
    %Extract the features.
    [f1, vpts1] = extractFeatures(I11, points1);
    [f2, vpts2] = extractFeatures(I22, points2);
    
    %Retrieve the locations of matched points. The SURF feature vectors are already normalized.
    indexPairs = matchFeatures(f1, f2, 'Prenormalized', true) ;
    matched_pts1 = vpts1(indexPairs(:, 1),:);
    matched_pts2 = vpts2(indexPairs(:, 2),:);
    
    %Display the matching points. The data still includes several outliers,
    %but you can see the effects of rotation and scaling on the display of matched features.
    if size(matched_pts1,1)<3
        isMotion=1;
        dist=10000;
    else
        [tform, ~, ~] = estimateGeometricTransform(matched_pts1, matched_pts2, 'affine');
        newBoxPolygon = transformPointsForward(tform, boxPolygon);
        dist=axis_change(boxPolygon,newBoxPolygon);
        d=sqrt(dist(1,1)*dist(1,1)+dist(1,2)*dist(1,2));
        if d<1
            isMotion=0;
        else
            isMotion=1;
        end
    end    
else
    error('unknown feature matching method')
end