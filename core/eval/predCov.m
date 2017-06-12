function [Ksy] = predCov(Ky, trainset, testset)

N = length(Ky);

assert(all(ismember(trainset, 1:N)));

Ksy = Ky - Ky(:, trainset) ...
  * inv( Ky(trainset,trainset) ) ...
  * Ky(trainset, :);

if nargin == 3
  if isempty(testset), testset = comple(trainset, N); end
  assert(  all(ismember(testset, 1:N     )) );
  assert( ~any(ismember(testset, trainset)) );
  Ksy = Ksy(testset, testset);
end
