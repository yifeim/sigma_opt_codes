function [Ci] = LplusCol(L, i, opts)

if nargin==3
  impatiencedisp = get_option(opts,'impatiencedisp',@(x) x);
end
d = size(L,1);
yi = (eye(d)-ones(d)/d)*[zeros(i-1,1);1;zeros(d-i,1)];

tic;
Iis = L(1:end-1, 1:end-1) \ yi(1:end-1);
linsolvetime = toc;
impatiencedisp(['linsolvetime in L+ comp: id=',num2str(i), ...
  ' time(s)=', num2str(linsolvetime)]);

Ci = (eye(d)-ones(d)/d)*[Iis;0];
