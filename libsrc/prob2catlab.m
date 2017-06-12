function [catlabs] = prob2catlab(y, cutoff)

% check if already catlabs
if ~isvector(y),
  catlabs=y; 
  warning('Already catlabs'); 
  return; 
end;

if nargin<2, cutoff=0; end

y = (y>cutoff);

catlabs = [y(:)'==0; y(:)'==1];

end
