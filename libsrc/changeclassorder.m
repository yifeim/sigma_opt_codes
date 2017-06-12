function [new_labels, new_classes] = changeclassorder( ...
  labels, old_classes, new_classes)

% --------------------------- sanity check ------------------------------

if size(labels, 1) > 1,
  warning('using from catlab to numlab');
  labels = cat2nomlab(labels);
end
