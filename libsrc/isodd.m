function [ret] = isodd(num, modulo)

if mod(num, modulo)==1
  ret = true;
else
  ret = false;
end
