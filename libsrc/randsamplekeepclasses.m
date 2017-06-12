function [ind, rng_seed, note] = randsamplekeepclasses(catlabs, rate)
% randsample keeping all classes in the sample

if size(catlabs, 1)==1, warning('catlab required, seeing 1d labels'); end

valid_sample = false;

rng('shuffle');
rng_seed = rng

while ~valid_sample
  ind = randsample(1:size(catlabs,2), ceil(size(catlabs,2)*rate));
  if all(sum(catlabs(:, ind), 2))
    valid_sample = true;
  end
end

note = sprintf(' sample the data by rate=%f, i.e. %d sample pts. ', ...
  rate, ceil(size(catlabs,2)*rate) );
