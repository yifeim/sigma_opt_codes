function [W, gnd, connectedPos, varargout]=largestgraphconncomp(W, gnd, varargin)
% function [W, gnd, connectedPos, varargout]=largestgraphconncomp(W, gnd, varargin)

[compNum, compId] = graphconncomp(sparse(W));
[~, largestCompId] = max(histc(compId, 1:compNum));
connectedPos = find(compId == largestCompId);

W = W(connectedPos, connectedPos);
if nargin>1, 
  gnd = gnd(:,connectedPos); 
else
  warning('gnd not specified'); 
  gnd=[]; 
end

if exist('varargin','var')
  for i=1:length(varargin)
    varargout{i} = varargin{i}(connectedPos);
  end
end
  
