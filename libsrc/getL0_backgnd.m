function [L0,A] = getL0_backgnd(sufficient_backgnd)

features = sufficient_backgnd.features;
k        = sufficient_backgnd.k; 


num_nodes = size(features,2);

neighbors = knnsearch(features', features', 'k', k);

selfs = repmat( (1:num_nodes)', [1, k]);
E = accumarray([selfs(:), neighbors(:)], 1, [num_nodes, num_nodes]);

A = (E + E')/2;

L0 = diag(sum(A)) - A;

% backgnd.k = k;
% sufficient_backgnd = backgnd;
% backgnd.sE = sparse(E);
% backgnd.sA = sparse(A);
% backgnd.sL0 = sparse(diag(sum(A)) - A);

end
