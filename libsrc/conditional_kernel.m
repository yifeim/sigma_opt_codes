function [C] = conditional_kernel(K, known_ind, tS)

if nargin<3, tS = zeros(length(known_ind)); end

C = K - K(:,known_ind) * inv(K(known_ind, known_ind) + tS) * K(known_ind, :);

