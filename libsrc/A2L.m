function [L] = A2L(A, delta)

default delta=0;

L = diag(sum(A)) - A + delta*eye(size(A));
