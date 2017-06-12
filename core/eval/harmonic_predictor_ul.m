function [predictor] = harmonic_predictor_ul(L,ell)

u = comple(ell, length(L))';
  predictor = -L(u,u)\L(u,ell); 
  
  
