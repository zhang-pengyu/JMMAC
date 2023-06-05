function [ res ] = polygon2pos( polygon, target_sz )

if length(polygon) == 4
    res = round([polygon(1,2)+target_sz(2)/2-1, polygon(1,1)+target_sz(1)/2-1]);
else
    res = ploygon;

end

