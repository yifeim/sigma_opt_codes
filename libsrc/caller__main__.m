function [flag] = caller__main__(disp_flag)

[st] = dbstack();

if nargin && disp_flag
  dbstack();
end

flag = length(st)==2;
