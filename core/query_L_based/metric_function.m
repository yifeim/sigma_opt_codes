function [outs, varargout] = metric_function( ...
  listOfQMetrics, u, y, Covtt, prior)
% listOfMetrics, u, y, Covtt
% margin_heur_all, accuracy_heur_all, sum_heur, tr_heur, bin_ent_heur,
% accuracy, loglike, survey, frac_survey

if nargin>=5
  y = y - prior;
  u = u - prior;
end

if ~iscell(listOfQMetrics), listOfQMetrics = {listOfQMetrics}; end
outs = struct();
for i=1:length(listOfQMetrics), outs.(listOfQMetrics{i})=nan; end

for i=1:length(listOfQMetrics)
  qualityMetric = listOfQMetrics{i};
  
  if strcmpi(qualityMetric, 'margin_heur_all')
    outs.(qualityMetric) = fcn_margin_heur_all(u);
    
  elseif strcmpi(qualityMetric, 'margin_heur')
    outs.(qualityMetric) = mean(fcn_margin_heur_all(u));
    
  elseif strcmpi(qualityMetric, 'accuracy_heur_all')
    outs.(qualityMetric) = fcn_accuracy_heur_all(u);
    
  elseif strcmpi(qualityMetric, 'accuracy_heur')
    outs.(qualityMetric) = mean(fcn_accuracy_heur_all(u));
    
  elseif strcmpi(qualityMetric, 'sum_heur')
    outs.(qualityMetric) = sum(sum(Covtt));
    
  elseif strcmpi(qualityMetric, 'tr_heur')
    outs.(qualityMetric) = trace(Covtt);
    
  elseif strcmpi(qualityMetric, 'bin_ent_heur')
    outs.(qualityMetric) = fcn_ent_Z_prob(u, Covtt);

  elseif strcmpi(qualityMetric, 'accuracy')
    outs.(qualityMetric) = fcn_accuracy(u, y);
  
  elseif strcmpi(qualityMetric, 'rmse')
    outs.(qualityMetric) = fcn_rmse(u, y);
  
  elseif strcmpi(qualityMetric, 'loglike')
    [~, outs.(qualityMetric)] =  fcn_ent_Z_prob(u, Covtt, y);
  
  elseif strcmpi(qualityMetric, 'survey')
    outs.(qualityMetric) = fcn_survey(u, y);
    
  elseif strcmpi(qualityMetric, 'frac_survey')
    outs.(qualityMetric) = fcn_survey(u, y);
    
  elseif strcmpi(qualityMetric, 'trunc_survey')
    outs.(qualityMetric) = fcn_trunc_survey(u,y);
    
  end
end
varargout = struct2cell(outs);
end

function [] = check_catprob(u)
assert(size(u,1) >= 2);
% if max(abs(sum(u) - 1)) > 1e-5, warning([inputname(1),' did not sum to 1.']); 
% disp(u);
% end
end

function [obj] = fcn_margin_heur_all(u)
check_catprob(u);
obj = [1,-1,zeros(1,size(u,1)-2)] * sort(u,'descend');
end

function [obj] = fcn_accuracy_heur_all(u)
check_catprob(u);
obj = max(u,[],1);
end


function [varargout] = fcn_ent_Z_prob( u, Covtt, y )
persistent pu pCovtt plogZ pent;
default pu=[];
default pCovtt=[];
if ~mateq(u, pu) || ~mateq(Covtt, pCovtt)
  pu=u; pCovtt=Covtt;
  [plogZ, pent] =  normalizer_cat_prob(u', inv(Covtt));
end
varargout{1} = pent;

default y=nan;
if all(all(isfinite(y))) 
  varargout{2} = joint_loglike(u', y', inv(Covtt), [], plogZ);
end
end


function [obj] = fcn_accuracy(u, y)
if isvector(u), u = prob2catlab(u>0); end
if isvector(y), y = prob2catlab(y>0); end
check_catprob(u); check_catprob(y);
catbinpred = y2label(u); %(bsxfun(@minus, u, max(u))==0);
obj = mean(catbinpred(logical(y2label(y))));
end

function [obj] = fcn_rmse(u, y)
uydiff = u-y;
obj = rms(uydiff(:));
end

function [obj] = fcn_trunc_survey(u, y)
if isvector(u), u = prob2catlab(u>0); end
if isvector(y), y = prob2catlab(y>0); end
check_catprob(u); check_catprob(y);
catbinpred = y2label(u); %(bsxfun(@minus, u, max(u))==0);
obj = sqrt( meansqr( mean(catbinpred - y, 2) ) );
end

function [obj] = fcn_survey(u, y)
% check_catprob(u); check_catprob(y);
obj = sqrt( meansqr( mean(u - y, 2) ) );
end

