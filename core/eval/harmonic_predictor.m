function [predictor] = harmonic_predictor(L,ell)

u = setdiff(1:length(L), ell);
  predictor = zeros(length(L));
  predictor(ell, ell) = eye(length(ell));
  predictor(u,ell) = -L(u,u)\L(u,ell);

  
