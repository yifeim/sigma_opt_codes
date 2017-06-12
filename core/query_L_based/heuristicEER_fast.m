function [obj2min] = heuristicEER_fast( ...
  method, isrgrsn, labels, testind, queryseq, unQed, pool, predCovCQ, Laplacian)
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

if ~any(strcmpi(method,{'eer'})),
  warning([' method ', method, num2str(isrgran), ' unexpected! ']);
end

impatiencedisp = @disp;

C = size(labels,1);
LC_CQ = Laplacian*predCovCQ;
catprob = -labels(:, queryseq) * LC_CQ(queryseq, :); ...Laplacian(queryseq,:) * predCovCQ;

% assert(1e-6 > sum(sum(abs(catprob(:,queryseq)))));

for poolItr = 1:length(pool)
  
  if abs(log(poolItr)/log(5) - round(log(poolItr)/log(5)))<1e-10
    curtime = toc;
    impatiencedisp([length(queryseq)+1,  poolItr, curtime]);
  end
  
  y = pool(poolItr);
  onestep_unQed = unQed(unQed ~= y);
  metric_ret = nan(1,C);
  
  multiplier_difference = (predCovCQ(y,onestep_unQed) / predCovCQ(y,y));
  
  for candcls=1:C
    
    condy_catprob = -catprob(:,y);
    condy_catprob(candcls) = 1 + condy_catprob(candcls); 
    
    harmonic_at_u_candcls = catprob(:, onestep_unQed) + ...
      condy_catprob * multiplier_difference;
    
    %     [~, metric_ret(candcls)] = metric_function( 'accuracy_heur', ...
    %       harmonic_at_u_candcls, labels(:,onestep_unQed), []);

    metric_ret(candcls) = meanmax(harmonic_at_u_candcls);

    %     metric_ret_old = mean( max(harmonic_at_u_candcls) );
    %     assert(metric_ret(candcls)==metric_ret_old);
    
    optimize = 'max';
    
  end
  switch optimize
    case 'max', obj2min(poolItr) = -metric_ret*catprob(:,y);      
      %         harmonic_at_u = catprob(:, testset) + ...
      %           (catprob(:,y) - catprob(:,y).^2) * predCovCQ(y, testset)/predCovCQ(y,y) ;
    case 'min', obj2min(poolItr) =  metric_ret*catprob(:,y);
  end
end

