function [V] = eig_cent(A, queryseq)

unQed = comple(queryseq, length(A));
[V,D] = eigs(A(unQed, unQed),1);
