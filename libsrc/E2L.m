function [L, A] = E2L(E, delta)

default delta=0;

A = ceil((E+E') / 2);
L = diag(sum(A)) - A + delta*eye(size(A));
