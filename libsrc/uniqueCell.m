function [C] = uniqueCell(C, equal_handle)

default equal_handle = @(x,y) strcmpi(x,y)

C = C(:);

i = 1;
while i <= length(C)
  j = i+1;
  while j <= length(C)
    if equal_handle(C{i}, C{j})
      C = [C(1:j-1); C(j+1:end)];
    else
      j = j+1;
    end
  end
  i=i+1;
end

