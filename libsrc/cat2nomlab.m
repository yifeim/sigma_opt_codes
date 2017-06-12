function [nomlab] = cat2nomlab(catlabs)

catlabs = y2label(catlabs);

[dim, N] = size(catlabs);
nomlab = nominal((1:dim)*catlabs);
