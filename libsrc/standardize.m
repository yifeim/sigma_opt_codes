function [stdedX] = standardize(X, dim)
if ~exist('dim','var') || isempty(dim)
  dim=1;
end
meanX = nanmean(X, dim);
stdX = nanstd(X, 1, dim);
stdedX = bsxfun(@rdivide, bsxfun(@minus, X, meanX), stdX);
