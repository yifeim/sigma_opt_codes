function [queryseq, greedyObj] = easy_active_query_clsfctn_rgrsn(...
  heuristic, Laplacian, catlabs, firstQuery, isrgrsn, opts)

default opts=struct();

useOrigCov = get_option(opts, 'useOrigCov', false);

debugdisp = get_option(opts, 'debugdisp', @(x) x);
impatiencedisp = get_option(opts, 'impatiencedisp', @disp);


narginchk(5,inf);

% parameters
% default method = 'sum';
% default isrgrsn = (size(labels,1)==1);

% N
if ~isrgrsn && graphconncomp(sparse(Laplacian)) > 1, warning('graphconncomp > 1'); end
if ~isrgrsn && ~(min(sum(Laplacian))>-1e-10 && max(max(triu(Laplacian, 1)))<1e-10),
  warning('non-singular Laplacian'); end
assert( size(Laplacian,1)==size(catlabs,2) );
N = size(Laplacian,1);

% C
catlabs = full(catlabs);
C = size(catlabs,1);

% test set
testind = true(1, size(Laplacian,1));

% pool set & queryLen
pool = 1:size(Laplacian, 1);
queryLen = get_option(opts, 'queryLen', 50);
queryLen = min(queryLen, length(pool));

greedyObj=[];

% existing queryseq
if isnumeric(firstQuery)
  queryseq = firstQuery;
  if ~all(ismember(firstQuery, pool)), warning('firstQuery not in pool'); end
% elseif strncmpi(firstQuery,'deterministic',3) && ~isrgrsn...
%     && any(strcmpi(heuristic, {'ep1','ep2','tr','sum'}))
%   warning('only for true graphs');
% 
%   obj2min = nan(size(pool));
%   for poolItr = 1:length(pool)
%     y = pool(poolItr);
%     predCov = inv(Laplacian([1:y-1,y+1:end], [1:y-1,y+1:end]));
%     switch(heuristic)
%       case {'ep2','tr'}
%         obj2min(poolItr) = trace(predCov);
%       case {'ep1','sum'}
%         obj2min(poolItr) = sum(sum(predCov));
%     end
%   end
%   
%   [greedyObj, poolItr2Query] = min(obj2min);
%   query = pool(poolItr2Query);
%   queryseq = query;

else % random
  if ~strcmpi(firstQuery, 'random'), warning('force 1stQ to random'); end
  queryseq = pool(randsample(length(pool), 1));
end
queryseq = queryseq(:)';

% update unobserved & pool sets
unQed = setdiff(1:N, queryseq);
pool = setdiff(pool, queryseq);

% predCov for unobserved
if ~useOrigCov
  tic;
  predCovCQ=zeros(N);
  predCovCQ(unQed,unQed) = inv(Laplacian(unQed,unQed));
  invTime=toc; debugdisp(invTime);
else
  origCov = get_option(opts, 'origCov', Laplacian);
  
  if any(size(origCov)~=N), warning('optPseudoCov mismatch'); end
  predCovCols = origCov(:, queryseq);
  predCovCQ = origCov ...
    -(predCovCols/predCovCols(queryseq, :))*predCovCols';
  
  predCovCQ(:,queryseq) = 0;
  predCovCQ(queryseq,:) = 0;
  predCovCQ = (predCovCQ+predCovCQ')/2;
end


tic;

% censure method
if strcmpi(heuristic, 'eer')
  if isrgrsn, 
    heuristic='tr'; 
  end
end

if strcmpi(heuristic, 'tr'),  heuristic='ep2'; end

for querySize=length(queryseq)+1 : queryLen
  tic;
  assert(issorted(unQed) && issorted(pool));
  obj2min = nan(size(pool));
  if length(pool) == 1
    obj2min = inf;
  else
    switch heuristic
      case 'rand'
        obj2min = rand(size(pool));
      case 'us'
        catprob = -catlabs(:, queryseq) * Laplacian(queryseq,:) * predCovCQ;
        obj2min = --[1,-1,zeros(1,C-2)] * sort(catprob(:,pool),1,'descend');
      
      case {'sum'}
        if mod(querySize, 10)==2,
          disp([num2str(querySize), '/', num2str(queryLen), '@', heuristic]);
        end
        
        for poolItr = 1:length(pool)
          y = pool(poolItr);
          %bug      testset = setdiff(intersect(find(testind), unQed), y);
          cand_inner_product = 1/sqrt(predCovCQ(y, y)) * predCovCQ(unQed, y);
          obj2min(poolItr) = -sum(cand_inner_product);
        end
        
      case {'ep_5', 'ep1', 'ep1_5', 'ep2'}
        if mod(querySize, 10)==2,
          disp([num2str(querySize), '/', num2str(queryLen), '@', heuristic]);
        end
        
        method_ep = str2double(strrep(heuristic(3:end),'_','.'));
        
        for poolItr = 1:length(pool)
          y = pool(poolItr);
          % bug    testset = setdiff(intersect(find(testind), unQed), y);
          cand_inner_product = 1/sqrt(predCovCQ(y, y)) * predCovCQ(unQed, y);
          obj2min(poolItr) = -sum(abs(cand_inner_product).^method_ep);
        end
        
      case 'ig'
        for poolItr=1:length(pool)
          y = pool(poolItr);
          obj2min(poolItr) = - predCovCQ(y,y);
        end
        
      case 'mig'
        for poolItr=1:length(pool)
          y = pool(poolItr);
          testset = intersect(find(testind), unQed);
          compleT = union(comple(testset,N), y);
          
          if ~(mateq(compleT, union(queryseq,y))), warning('mig set'); end;
          
          predCovCTmy = zeros(N);
          predCovCTmy(compleT,compleT) = inv(Laplacian(compleT,compleT));
          obj2min(poolItr) = - predCovCQ(y,y) / predCovCTmy(y,y);
        end
        
      case {'eer','minbe','maxbe'}
        %look ahead
        if ~isrgrsn,
          obj2min = heuristicEE( ...
            heuristic, isrgrsn, catlabs, testind, queryseq, ...
            unQed, pool, predCovCQ, Laplacian);
        end
        
      case {'loglike'}
        %look ahead
        if ~isrgrsn,
          obj2min = heuristicCheat( ...
            heuristic, isrgrsn, catlabs, testind, queryseq, ...
            unQed, pool, predCovCQ, Laplacian);
        end
        
      case {'cheat','cheat_survey','cheat_rmse','cheat_accuracy'}
        %look ahead
        obj2min = heuristicCheat( ...
          heuristic, isrgrsn, catlabs, testind, queryseq, ...
          unQed, pool, predCovCQ, Laplacian);

    end
    
    if any(isnan(obj2min)),
      warning([heuristic, ' is not implemented , treated as random']);
      obj2min = rand(size(pool));
    end
  end
  
  
  [greedyObj(querySize), poolItr2Query] = min(obj2min);
  query = pool(poolItr2Query);
  queryseq(querySize) = query;
  predCovCols = 1/sqrt(predCovCQ(query, query)) * predCovCQ(:, query);
  predCovCQ = predCovCQ - predCovCols*predCovCols';
  if ~isrgrsn && any(any(abs(predCovCQ(:,query)) > 1e-10))
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

