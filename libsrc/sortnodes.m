function [old_node_ind, catlabs, A, varargout] = sortnodes(catlabs, A, varargin)
% function [old_node_ind, catlabs, A, varargout] = sortnodes(catlabs, A, varargin)


% sort nodes 
[~, old_node_ind] = sort(double(cat2nomlab(catlabs)), 'ascend');
catlabs    = catlabs(:, old_node_ind);


if exist('A','var') && ~isempty(A)
  A = A(old_node_ind, old_node_ind);
else 
  A = [];
end

for i=1:length(varargin)
  varargout{i} = varargin{i}(old_node_ind);
end
