function [A,labels] = subgraph(A, labels, ind)

A = A(ind, ind);

if isvector(labels), labels = labels(:)'; end

labels = labels(:, ind);

end
