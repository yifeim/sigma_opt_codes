function [sort_order] = sortcatlabs(catlabs)

[~,sort_order] = sort(cat2nomlab(y2label(catlabs)));
