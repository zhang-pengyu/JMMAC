function [dist]=axis_change(bbox1,bbox2)%bbox1原图，bbox2目标图
cx1=mean(bbox1(1:4,1));
cy1=mean(bbox1(1:4,2));
cx2=mean(bbox2(1:4,1));
cy2=mean(bbox2(1:4,2));
dist=[cx2-cx1,cy2-cy1];
