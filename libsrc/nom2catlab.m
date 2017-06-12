function [catlabs] = nom2catlab(labels)

% check if already catlabs
if ~isvector(labels),
  catlabs=labels; 
  warning('Already catlabs'); 
  return; 
end;

classes = unique(labels);

catlabs = [];
for i=1:length(classes)
  catlabs(i,:) = (labels==classes(i));
end

end
