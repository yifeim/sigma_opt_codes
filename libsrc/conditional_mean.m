function [f] = conditional_mean(K, known_ind, ty, tS)

if nargin<4, tS = zeros(length(known_ind)); end
if nargin<3, ty = ones(size(known_ind)); end

f = K(:,known_ind) * ( (K(known_ind, known_ind) + tS) \ ty(:) );

