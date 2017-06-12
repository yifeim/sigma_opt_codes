function [Ksf, Ksy] = predCovfy(Kf, sn2, trainset, testset)

N = length(Kf);

assert(all(ismember(trainset, 1:N)));

Ksf = Kf - Kf(:, trainset) ...
  * inv(Kf(trainset,trainset) + eye(length(trainset)) * sn2) ...
  * Kf(trainset, :);
Ksy = Ksf ...
  + eye(N) * sn2;

if nargin == 4
  assert(  all(ismember(testset, 1:N     )) );
  assert( ~any(ismember(testset, trainset)) );
  Ksf = Ksf(testset, testset);
  Ksy = Ksy(testset, testset);
end
