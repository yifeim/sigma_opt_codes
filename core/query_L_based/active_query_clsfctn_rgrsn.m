function [queryseq, greedyObj, initPredCov] = active_query_clsfctn_rgrsn(...
  method, Laplacian, labels, testind, firstQuery, queryLen, ...
  poolConstraint, isrgrsn, sparsifyCov, verbose, allowQinTest,  predCovCQ)
% method='eer','us','sum','tr','mig'; accel=T/F; sparsify=T/F; verbose=T/F;
% Laplacian;
% labels (bin or cat); testind=T(1:N); queryLen=50;  allowQinT=all(testind);
% poolConstraint=1:N; firstQuery='random','exact','maxdeg',QSeq; predCov;

impatiencedisp = @disp;

% parameters
default method = 'sum';
default isrgrsn = (size(labels,1)==1);
% default(['sparsifyCov = (' ...
%   'size(largestgraphconncomp(sparse(Laplacian)), 1)' ...
%   '/size(Laplacian, 1) < .1)']);
default sparsifyCov = false;
% default verbose = isrgrsn;
default verbose = false;
if verbose, debugdisp=@disp; else debugdisp = @(x) x; end;

% N
% if graphconncomp(sparse(Laplacian)) > 1, warning('graphconncomp > 1'); end
if ~(min(sum(Laplacian))>-1e-10 && max(max(triu(Laplacian, 1)))<1e-10),
  warning('non-singular Laplacian'); end
assert( size(Laplacian,1)==size(labels,2) );
N = size(Laplacian,1);

% C
labels = full(labels);
C = size(labels,1);

% test set
default testind = 0;
if ~any(testind)
  testind = true(1, size(Laplacian,1));
  allowQinTest = true;
end
if ~islogical(testind)
  testind = full(sparse(testind, 1, true, size(Laplacian, 1), 1));
end
if length(testind) ~= size(Laplacian, 1), warning('testind mismatch'); end
testind = reshape(testind, 1, numel(testind));

% pool set & queryLen
default poolConstraint = 1:size(Laplacian, 1);
default allowQinTest   = all(testind);
if allowQinTest
  pool  = poolConstraint;
else
  pool  = intersect(poolConstraint, find(~testind));
end
default queryLen = min(50, length(pool));

% existing queryseq
default('firstQuery = ''largestdegree''');
if isnumeric(firstQuery)
  queryseq = firstQuery;
  if ~all(ismember(firstQuery, pool)), warning('firstQuery not in pool'); end
elseif strcmpi(firstQuery, 'largestdegree')
  [~, queryPoolPtr] = max(diag(Laplacian(pool,pool)));
  queryseq = pool(queryPoolPtr);
elseif strcmpi(firstQuery, 'first')
  queryseq = pool(1);
else %random
  if ~strcmpi(firstQuery, 'random'), warning('force 1stQ to random'); end
  queryseq = pool(randsample(length(pool), 1));
end
queryseq = reshape(queryseq, 1, numel(queryseq));

% update unobserved & pool sets
unQed = setdiff(1:N, queryseq);
pool = setdiff(pool, queryseq);

% predCov for unobserved
if ~exist('predCov','var') || isempty(predCovCQ)
  tic;
  predCovCQ=zeros(N);
  predCovCQ(unQed,unQed) = inv(Laplacian(unQed,unQed));
  invTime=toc; debugdisp(invTime);
elseif any(size(predCovCQ)~=N), warning('predCov mismatch');
elseif any(any(predCovCQ(:,pool) ~= 0)), warning('predCov nonzero in pool');
end
if sparsifyCov, predCovCQ = sparse(predCovCQ); else  predCovCQ = full(predCovCQ); end

initPredCov = {queryseq, predCovCQ};

tic;

% censure method
if strcmpi(method, 'eer')
  if isrgrsn, 
    method='tr'; 
  end
end

if strcmpi(method, 'tr'),  method='ep2'; end

greedyObj = [];
for querySize=length(queryseq)+1 : queryLen
  tic;
  assert(issorted(unQed) && issorted(pool));
  obj2min = nan(size(pool));
  if length(pool) == 1
    obj2min = inf;
  else
    switch method
      case 'rand'
        obj2min = rand(size(pool));
      case 'us'
        catprob = -labels(:, queryseq) * Laplacian(queryseq,:) * predCovCQ;
        obj2min = --[1,-1,zeros(1,C-2)] * sort(catprob(:,pool),1,'descend');
      
      case {'sum'}
        if mod(querySize, 10)==2,
          disp([num2str(querySize), '/', num2str(queryLen), '@', method]);
        end
        
        for poolItr = 1:length(pool)
          y = pool(poolItr);
          testset = intersect(find(testind), unQed);
          cand_inner_product = 1/sqrt(predCovCQ(y, y)) * predCovCQ(testset, y);
          obj2min(poolItr) = -sum(cand_inner_product);
        end
        
      case {'ep_5', 'ep1', 'ep1_5', 'ep2'}
        if mod(querySize, 10)==2,
          disp([num2str(querySize), '/', num2str(queryLen), '@', method]);
        end
        
        method_ep = str2double(strrep(method(3:end),'_','.'));
        
        for poolItr = 1:length(pool)
          y = pool(poolItr);
          testset = intersect(find(testind), unQed);
          cand_inner_product = 1/sqrt(predCovCQ(y, y)) * predCovCQ(testset, y);
          obj2min(poolItr) = -sum(abs(cand_inner_product).^method_ep);
        end
        
      case 'ig'
        for poolItr=1:length(pool)
          y = pool(poolItr);
          obj2min(poolItr) = - predCovCQ(y,y) ;
        end
        
      case 'mig'

        invL_ell = inv(Laplacian(queryseq, queryseq));
        L_ell_pool = Laplacian(queryseq, pool);
        % dispimpatience(querySize); dispclock(0); %%
        for poolItr=1:length(pool)               
          y = pool(poolItr);                     
          % compleT = union(comple(unQed,N),y);    %%
          
          % if ~(mateq(compleT, union(queryseq,y))), warning('mig set'); end; %%
          
          % predCovCTmy = zeros(N);                %%
          % predCovCTmy(compleT,compleT) = inv(Laplacian(compleT,compleT)); %%
          % fast predCovCTmy = d(y) - L(y,ell) L(ell,ell)^-1 L(ell,y)
          L_ell_y = L_ell_pool(:, poolItr);
          fastInvPredCovCTmy = Laplacian(y,y) - L_ell_y' * invL_ell * L_ell_y;
          % assert(abs(fastInvPredCovCTmy - predCovCTmy(y,y).^-1) < 1e-10); %%
          % disp([poolItr, length(pool)]);
          obj2min(poolItr) = - predCovCQ(y,y) * fastInvPredCovCTmy;
        end
        
%        disp([num2str(querySize), '/', num2str(queryLen), '@', method]);
%        
%        for poolItr=1:length(pool)
%          y = pool(poolItr);
%          testset = intersect(find(testind), unQed);
%          compleT = union(comple(testset,N), y);
%          
%          if ~(mateq(compleT, union(queryseq,y))), warning('mig set'); end;
%          
%          predCovCTmy = zeros(N);
%          predCovCTmy(compleT,compleT) = inv(Laplacian(compleT,compleT));
%          obj2min(poolItr) = - predCovCQ(y,y) / predCovCTmy(y,y);
%        end
        
      case {'eer','minbe','maxbe'}
        
        if mod(querySize, 10)==2,
          disp([num2str(querySize), '/', num2str(queryLen), '@', method]);
        end
        
        %look ahead
        if ~isrgrsn,
          obj2min = heuristicEE( ...
            method, isrgrsn, labels, testind, queryseq, ...
            unQed, pool, predCovCQ, Laplacian);
        end
        
      case {'loglike'}
        %look ahead
        if ~isrgrsn,
          obj2min = heuristicCheat( ...
            method, isrgrsn, labels, testind, queryseq, ...
            unQed, pool, predCovCQ, Laplacian);
        end
        
      case {'cheat','cheat_survey','cheat_rmse','cheat_accuracy'}
        %look ahead
        obj2min = heuristicCheat( ...
          method, isrgrsn, labels, testind, queryseq, ...
          unQed, pool, predCovCQ, Laplacian);

    end
    
    if any(isnan(obj2min)),
      warning([method, ' is not implemented , treated as random']);
      obj2min = rand(size(pool));
    end
  end
  
  
  [greedyObj(querySize), poolItr2Query] = min(obj2min);
  query = pool(poolItr2Query);
  queryseq(querySize) = query;
  predCovCol = 1/sqrt(predCovCQ(query, query)) * predCovCQ(:, query);
  predCovCQ = predCovCQ - predCovCol*predCovCol';
  if any(any(abs(predCovCQ(:,query)) > 1e-10))
    warning([  'predCovCQ nonzero in pool, =' ...
      num2str(max(max(abs(predCovCQ(:,query)))))  ]);
  end
  predCovCQ(:,query) = 0;
  predCovCQ(query,:) = 0;
  unQed = unQed(unQed~=query);
  pool = pool(pool~=query);
  
  loopTime = toc;
  debugdisp([querySize, loopTime, queryseq(end)]);
  if isempty(pool), break; end
  %   disp(round(clock));
  %   if mod(querySize,25)==25, save('tmp2.mat'); disp('tmp save'); end;
end

end

