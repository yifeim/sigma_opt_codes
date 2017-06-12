function [obj2min] = heuristicCheat( ...
  heuristic, isrgrsn, labels, testind, queryseq, unQed, pool, predCovCQ, Laplacian)
  % this is only for clsfctn, eer/minbe/maxbe
  %
  % for those that need label_y:
  %   eer/minbe/maxbe/loglike (clsfctn) & cheat (both)
  %   in these:
  %     eer/minbe/maxbe (clsfctn) are non-cheat, i.e., loop candcls
  %     loglike (clsfctn) / cheat (both) are cheat
  % others (need no more than Cov): 
  %   rand
  %   ep*  
  %   sum=ep1, tr=ep2, eer(rgrsn)=tr=ep2
      % cheat: same for both
      % loglike, minbe, maxbe: only for clsfctn
      % sum, tr: may not be supported for either
      % eer: different between clsfctn/rgrsn

if ~any(strcmpi(heuristic,{'cheat','loglike','cheat_survey','cheat_rmse','cheat_accuracy'})),
  warning([' method ', heuristic, ' unexpected! ']);
end

impatiencedisp = @disp;

C = size(labels,1);
LC_CQ = Laplacian*predCovCQ;

for poolItr = 1:length(pool)
  
  if abs(log(poolItr)/log(5) - round(log(poolItr)/log(5)))<1e-10
    curtime = toc;
    impatiencedisp([length(queryseq)+1,  poolItr, curtime]);
  end
  
  y = pool(poolItr);
  predCovColy = 1/sqrt(predCovCQ(y, y)) * predCovCQ(:, y);
  testset = setdiff(intersect(find(testind), unQed), y);
  
  condition_labels = ...
    labels(:, [queryseq, y]);
    
  catprobCcandcls = ...
    - condition_labels * LC_CQ([queryseq, y], :) ... 
    -- (condition_labels * Laplacian([queryseq, y], :) * predCovColy)*predCovColy';
  
  metric_fcn_paras = {catprobCcandcls(:, testset), labels(:,testset), ...
    []};
    
  switch heuristic
    case {'loglike'}
      predCovCQy = predCovCQ - predCovColy*predCovColy';
      metric_fcn_paras{3} = predCovCQy(testset,testset);
  end
    
  switch heuristic
    case 'cheat'
      if isrgrsn
        heuristic = 'rmse'; optimize = 'min';
      else
        heuristic = 'accuracy'; optimize = 'max';
      end
      
    case 'cheat_rmse'
      heuristic = 'rmse'; optimize = 'min';
    case 'cheat_accuracy'
      heuristic = 'accuracy'; optimize = 'max';
      
    case 'cheat_survey'
      heuristic = 'frac_survey'; optimize = 'min';
      
    case 'loglike'
      heuristic = 'loglike'; optimize = 'max';
  end
    
  [~, metric_ret] = metric_function( heuristic, ...
      metric_fcn_paras{:});

  switch optimize
    case 'max', obj2min(poolItr) = -metric_ret;
    case 'min', obj2min(poolItr) =  metric_ret;
  end
end

