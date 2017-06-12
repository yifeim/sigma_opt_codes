function [subset, objective] = subset_selection(...
  heuristic, Laplacian, opts)

dbstop if error

default opts = struct('dummy',0);
opts.dummy = 0;
origCov = get_option(opts, 'Cov', []);

debugdisp = get_option(opts, 'debugdisp', @(x) x);
impatiencedisp = get_option(opts, 'impatiencedisp', @disp);


% N
% if graphconncomp(sparse(Laplacian)) > 1, warning('graphconncomp > 1'); end
if ~(min(sum(Laplacian))>-1e-10 && max(max(triu(Laplacian, 1)))<1e-10),
  warning('non-singular Laplacian'); end
N = size(Laplacian,1);

% full Laplacian
Laplacian = full(Laplacian);

% pool set & queryLen
pool = 1:size(Laplacian, 1);
queryLen = get_option(opts, 'queryLen', 2);
queryLen = min(queryLen, length(pool));


pools = combnk(1:N, queryLen);
obj2min = nan(size(pools,1),1);

% keyboard;

parfor poolItr = 1:size(pools,1)

  if mod(poolItr, 1000)==2,
    disp([num2str(poolItr), '/', num2str(queryLen), '@', heuristic]);
  end
  
  queryseq = pools(poolItr,:);
  unQed = setdiff(1:N, queryseq);

  predCovCQ = inv(Laplacian(unQed,unQed));
  
  switch heuristic
        
    case {'sum'}
      obj2min(poolItr) = sum(sum(predCovCQ));
        
    case {'tr'}
      obj2min(poolItr) = trace(predCovCQ);

    otherwise
      warning([heuristic, ' is not implemented , treated as tr']);
      obj2min(poolItr) = trace(predCovCQ);
    
  end
end
  
  [objective, poolItr2Query] = min(obj2min);
  subset = pools(poolItr2Query, :);
end

