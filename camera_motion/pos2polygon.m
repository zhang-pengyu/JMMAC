function res = pos2polygon(pos,target_sz)
if length(pos) == 2
    res = round([pos(1),pos(2);pos(1)+target_sz(1),pos(2);pos(1)+target_sz(1),pos(2)+target_sz(2);pos(1),pos(2)+target_sz(2)]);
else
    res = pos;
end