function [catlabs] = squeezecatlabs(catlabs, class_ids)

  default class_ids = find(sum(catlabs, 2));
 
  catlabs = catlabs(class_ids, :);
