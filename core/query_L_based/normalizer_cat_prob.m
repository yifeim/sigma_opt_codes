function [logZofloglinear, ent, logps,  nonreglogp, debugys] = ...
  normalizer_cat_prob( u, invCov, lambda )

if size(u, 1) ~= size(invCov, 1)
  warning('inconsistant input');
end
default lambda=1;

% p = g(invCov) exp(-lambda/nb_class (x-u)' invCov (x-u))
% log p = g'(invCov) - lambda/nb_class (x-u)' invCov (x-u)
N = size(u, 1);
C = size(u, 2);
coeff = .5/lambda;

L = chol(invCov);

assert(mateq(L'*L, invCov));

Lu = L*u;
% Lydif = L*ydif

% tic;
pyitr = zeros(C,1);
y = C*ones(N,1);
for yitr= 1:C^N
  for n=N:-1:1
    if y(n) < C
      y(n) = y(n)+1;
      break;
    else
      y(n) = 1; 
    end
  end
%   caty = accumarray([(1:N)', y], 1, [N, C]); 
%   ydif = caty - u;
  for c=1:C
    Lydifitr = L*(y==c) - Lu(:,c);
    pyitr(c) = - coeff * (Lydifitr' * Lydifitr);
%     pyitr2(c) = - coeff*ydif(:,c)' * invCov * ydif(:,c);
%     assert(mateq(pyitr(c), pyitr2(c)));
  end
  nonreglogp(yitr) = sum(pyitr);
  debugys(:,yitr) = y;
end
% toc;

logZ1 = max(nonreglogp);

logps = nonreglogp - logZ1;
logZ2 = log(sum(exp(logps)));
logps = logps - logZ2;
logZofloglinear = logZ1 + logZ2;
ent = sum(-exp(logps).*logps);
