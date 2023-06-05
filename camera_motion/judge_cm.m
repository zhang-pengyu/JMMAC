function  flagCM = judge_cm(imCurRGB, imCurIR, imRefRGB, imRefIR)
%% camera motion detection using RGB T image
% Input: current and reference images of RGB and T.
% Output: the flag indicates whether camera motion occurs.
    
%% parameter setting   
    rgbTr     = 15;
    irTr      = 10;
    sampleNum = 40;
    motinTr   = 0.1284;
%%
    if size(imCurIR,3) == 1
        imCurIR = cat(3,imCurIR,imCurIR,imCurIR);
    end
    if size(imRefIR,3) == 1
        imRefIR = cat(3,imRefIR,imRefIR,imRefIR);
    end
    imDiffRGB  = abs(double(medfilt2(rgb2gray(imCurRGB),[9 9]))-...
                     double(medfilt2(rgb2gray(imRefRGB),[9 9])));
    imDiffRGB  = imresize(imDiffRGB, [sampleNum sampleNum]);
    cmRatioRGB = sum(sum(imDiffRGB>rgbTr))/(sampleNum*sampleNum);
    imDiffIR  = abs(double(medfilt2(rgb2gray(imCurIR),[9 9]))-...
                    double(medfilt2(rgb2gray(imRefIR),[9 9])));
    imDiffIR  = imresize(imDiffIR, [sampleNum sampleNum]);
    cmRatioIR = sum(sum(imDiffIR>irTr))/(sampleNum*sampleNum);
    cmRatio   = 0.8*cmRatioRGB+0.2*cmRatioIR;
    flagCM    = (cmRatio>motinTr);

end