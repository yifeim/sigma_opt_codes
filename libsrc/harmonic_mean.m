function [f] = harmonic_mean(L, known_ind, ty)


if nargin<3, ty = ones(size(known_ind)); end

unkwn_ind = comple(known_ind, length(L));

f = nan(length(L),1);

f(unkwn_ind) = - L(unkwn_ind, unkwn_ind) \ ( L(unkwn_ind, known_ind) * ty(:) );
f(known_ind) = ty(:);
