function [labels] = y2label( y )

[dim, N] = size(y);

if max(max(y)) > 1 + 1e-5 || min(min(y)) < -1e-5
  warning([inputname(1), ' is not between [0,1], shifted and scaled, but there might be something wrong']);
 miny = min(min(y));
 maxy = max(max(y));
 y = (y-miny) / (maxy-miny);
end

% if any(abs( sum(y) - 1 ) > 1e-5)
%   warning(['sum(', inputname(1), ') is not 1. Scaled, but something might be wrong']);
%   y = bsxfun(@rdivide, y, sum(y));
% end

% [~, ova] = max(y); 
% labels = accumarray([ova', (1:N)'], 1);
labels = (bsxfun(@minus, y, max(y))==0);
