
function [ret, maxabsdiff] = mateq(mat1, mat2, tolerance)
if nargin<3, tolerance = 1e-9; end

if any(size(mat1) ~= size(mat2)) 
  ret=false; 
  maxabsdiff = nan;
else
  maxabsdiff = max(max(abs( mat1-mat2 )));
  ret = maxabsdiff < tolerance;
end
