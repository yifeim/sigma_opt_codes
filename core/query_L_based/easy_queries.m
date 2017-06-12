function [queryseq, greedyObj] = easy_queries(...
  heuristic, Laplacian, queryseq, opts)
% heuristics supported:  Sopt, Vopt, rand, mig, unc, EER 

% all checks are removed.

% graph needs to be connected.
% for classification, it is usually singular.

default opts=struct();
% catlab and C needed for real active learning algorithms, e.g. EER ow []0.
% queryseq<pool<all

dispclock = @(dummy) fprintf('===%d-%d-%d %d:%d:%.0f\n',clock);

% dispdebug = get_option(opts, 'dispdebug', @(x) x);
dispimpatience = get_option(opts, 'dispimpatience', @disp);
dispinfo = get_option(opts, 'dispinfo', @disp);


% N 
N = size(Laplacian,1);

% C for EER and other genuine active learning algorithms
catlabs = full(get_option(opts, 'catlabs', []));
C = size(catlabs,1);

isrgrsn = get_option(opts, 'isrgrsn', false);

% test set is always the entire set
testind = true(1, size(Laplacian,1));

% pool set , queryseq, & queryLen
pool = get_option(opts, 'pool', 1:size(Laplacian, 1));
queryLen = get_option(opts, 'queryLen', 50);

assert( queryLen < length(pool) );

queryseq = queryseq(:)';
assert(~isempty(queryseq));

greedyObj = get_option(opts, 'greedyObj', []);


% update unobserved & pool sets
unQed = setdiff(1:N, queryseq);
pool = setdiff(pool, queryseq);

% predCov for unobserved
if isfield(opts, 'K4all')
  K4all = get_option(opts, 'K4all', Laplacian);
  
  assert( all(size(K4all)==N) );
  predCovCols = K4all(:, queryseq);
  predCovCQ = K4all ...
    -(predCovCols/predCovCols(queryseq, :))*predCovCols';
  
  predCovCQ(:,queryseq) = 0;
  predCovCQ(queryseq,:) = 0;
  predCovCQ = (predCovCQ+predCovCQ')/2;
  
else
  tic;
  predCovCQ=zeros(N);
  predCovCQ(unQed,unQed) = inv(Laplacian(unQed,unQed));
%   invTime=toc; dispdebug(invTime);

end

dispinfo(opts); dispinfo(heuristic); dispclock(0);

tic;

% censure method
if strcmpi(heuristic, 'eer')
  if isrgrsn, 
    heuristic='tr'; 
  end
end

for querySize=length(queryseq)+1 : queryLen
  tic;
  assert(issorted(unQed) && issorted(pool));
  obj2min = nan(size(pool));
  if length(pool) == 1 
    obj2min = inf;
  else %2+ nodes left, so that mig won't fail.
    switch heuristic
      case 'rand'
        obj2min = rand(size(pool));
      case 'unc'
        catprob = -catlabs(:, queryseq) * Laplacian(queryseq,:) * predCovCQ;
        obj2min = --[1,-1,zeros(1,C-2)] * sort(catprob(:,pool),1,'descend');
      
      case {'sopt','sum'}
        for poolItr = 1:length(pool)
          y = pool(poolItr);
          %bug      testset = setdiff(intersect(find(testind), unQed), y);
          cand_inner_product = 1/sqrt(predCovCQ(y, y)) * predCovCQ(unQed, y);
          obj2min(poolItr) = -sum(cand_inner_product);
        end
        
      case {'vopt','tr'}
        for poolItr = 1:length(pool)
          y = pool(poolItr);
          % bug    testset = setdiff(intersect(find(testind), unQed), y);
          cand_inner_product = 1/sqrt(predCovCQ(y, y)) * predCovCQ(unQed, y);
          obj2min(poolItr) = -sum(abs(cand_inner_product).^2);
        end
        
      case {'ep_5', 'ep1', 'ep1_5', 'ep2'}
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
        
      case 'eer'
        if ~isrgrsn,
          obj2min = heuristicEER_fast( ...
            heuristic, isrgrsn, catlabs, testind, queryseq, ...
            unQed, pool, predCovCQ, Laplacian);
        end
        
      case {'eer0','eer1','minbe','maxbe'}
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
%   dispdebug([querySize, loopTime, queryseq(end)]); 
  if isempty(pool), break; end
end

end

