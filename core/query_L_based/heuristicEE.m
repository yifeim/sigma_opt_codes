function [obj2min] = heuristicEE( ...
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

if ~any(strcmpi(method,{'eer1','eer0','minbe','maxbe'})),
  warning([' method ', method, ' unexpected! ']);
end

impatiencedisp = @disp;

C = size(labels,1);
LC_CQ = Laplacian*predCovCQ;
catprob = -labels(:, queryseq) * LC_CQ(queryseq, :); ...Laplacian(queryseq,:) * predCovCQ;

for poolItr = 1:length(pool)
  
  if abs(log(poolItr)/log(5) - round(log(poolItr)/log(5)))<1e-10
    curtime = toc;
    impatiencedisp([length(queryseq)+1,  poolItr, curtime]);
  end
  
  y = pool(poolItr);
  testset = setdiff(intersect(find(testind), unQed), y);
  metric_ret = nan(1,C);
%   predCovColy = 1/sqrt(predCovCQ(y, y)) * predCovCQ(:, y);
  
  for candcls=1:C
    
%     condition_labels = ...
%       [labels(:,queryseq), full(sparse(candcls,1,true,C,1)) ];
%     
%     catprobCcandcls = ...
%       - condition_labels * LC_CQ([queryseq, y], :) ...Laplacian([queryseq, y], :) * predCovCQ ...
%       -- (condition_labels * Laplacian([queryseq, y], :) * predCovColy)*predCovColy';
%     
%     metric_fcn_paras = {catprobCcandcls(:, testset), labels(:,testset), ...
%       []};
    
    switch method
      case {'minbe','maxbe'}
        predCovCQy = predCovCQ - predCovColy*predCovColy';
        metric_fcn_paras{3} = predCovCQy(testset,testset);
    end
    
    switch method
      case 'minbe'
        heur = 'bin_ent_heur'; optimize = 'min';
      case 'maxbe'
        heur = 'bin_ent_heur'; optimize = 'max';
      case 'eer0'
        heur = 'accuracy_heur'; optimize = 'max';
        
      case 'eer1'
        harmonic_at_u_candcls = catprob(:, testset) + ...
          ( accumarray([candcls,1],true,[C,1]) - catprob(:,y) ) ...
          *predCovCQ(y,testset) / predCovCQ(y,y);
        
        metric_fcn_paras = {harmonic_at_u_candcls, labels(:,testset), []};
         
%         assert(mateq(harmonic_at_u_candcls, metric_fcn_paras{1}));

        heur = 'accuracy_heur'; optimize = 'max';
    end
    
    [~, metric_ret(candcls)] = metric_function( heur, ...
      metric_fcn_paras{:});
  end
  switch optimize
    case 'max', obj2min(poolItr) = -metric_ret*catprob(:,y);      
      %         harmonic_at_u = catprob(:, testset) + ...
      %           (catprob(:,y) - catprob(:,y).^2) * predCovCQ(y, testset)/predCovCQ(y,y) ;
    case 'min', obj2min(poolItr) =  metric_ret*catprob(:,y);
  end
end

