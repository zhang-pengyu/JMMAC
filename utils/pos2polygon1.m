function res = pos2polygon1(pos,target_sz)
if length(pos) == 2
    res = round([pos(2)-target_sz(2)/2,pos(1)-target_sz(1)/2;pos(2)+target_sz(2)/2-1,pos(1)-target_sz(1)/2;pos(2)+target_sz(2)/2-1,pos(1)+target_sz(1)/2-1;pos(2)-target_sz(2)/2,pos(1)+target_sz(1)/2-1]);
else
    res = pos;
end