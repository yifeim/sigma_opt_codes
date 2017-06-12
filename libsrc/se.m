function [out] = se(varargin)

if nargin==1
  dim = find(size(varargin{1}) ~= 1, 1);
  if isempty(dim), dim = 1; end
else
  dim = varargin{end};
end

out = std(varargin{:}) / sqrt(size(varargin{1}, dim));

