function [outs, varargout] = prediction_quality_basic( ...
  listOfQMetrics, cat_te_true, catprobpred, invCovtt)
% 'mse' 'accuracy' 'bin_entropy' 'joint_loglike' 'survey' 'frac_survey'

if ~iscell(listOfQMetrics), listOfQMetrics = {listOfQMetrics}; end
outs = struct();
for i=1:length(listOfQMetrics), outs.(listOfQMetrics{i})=nan; end

if min(size(invCovtt))==0, varargout = struct2cell(outs); return; end;

assert(all(size(cat_te_true)==size(catprobpred)));
C = size(catprobpred,1);
N = size(catprobpred, 2);

if any(strcmpi(listOfQMetrics,'bin_entropy')) || ...
    any(strcmpi(listOfQMetrics, 'joint_loglike'))
  
  [logZ, bin_entropy] =  normalizer_cat_prob(catprobpred', invCov);
end

for i=1:length(listOfQMetrics)
  qualityMetric = listOfQMetrics{i};
  if strcmpi(qualityMetric, 'mse')
    
    outs.mse = sqrt(meansqr( catprobpred - cat_te_true));
    
  elseif strcmpi(qualityMetric, 'accuracy')
    
    [~, predictions]    = max(catprobpred, [], 1);
    catbinpred = full(sparse(predictions, 1:size(catprobpred,2), true, ...
      size(catprobpred,1), size(catprobpred,2)));
    outs.accuracy = mean(catbinpred(cat_te_true));
  
  elseif strcmpi(qualityMetric, 'marginal_loglike')
    
    outs.marginal_loglike = 0;
    for n=1:N
      logZn = normalizer_cat_prob(catprobpred(:,n)', invCov(n,n));
      outs.marginal_loglike = outs.marginal_loglike + ...
        joint_loglike(catprobpred(:,n)', cat_te_true(:,n)', ...
        invCov(n,n), [], logZn);
    end
  
%     expfi = exp(bsxfun(@rdivide, catprobpred, diag(Covtt)'));
%     num = sum(cat_te_true.*expfi, 1);
%     den = sum(expfi, 1);
%     outs.marginal_loglike = full(sum(log(num./den)));

%     for clsitr = 1:size(catprobpred,1)
%       ova_bin_loglike(clsitr) = ...
%         sum(log(1-normcdf(abs(cat_te_true(clsitr, :) - catprobpred(clsitr, :)), ...
%         .5, sqrt(beta.*diag(Covtt)') )));
%     end
%     outs{end+1} = ova_bin_loglike;
  
  elseif strcmpi(qualityMetric, 'bin_entropy')
  
    outs.bin_entropy = bin_entropy;
  
  elseif strcmpi(qualityMetric, 'joint_loglike')
  
    outs.joint_loglike = ...
      joint_loglike(catprobpred', cat_te_true', invCov, [], logZ);
  
  elseif strcmpi(qualityMetric, 'survey')
  
    [~, predictions]    = max(catprobpred, [], 1);
    catbinpred = full(sparse(predictions, 1:size(catprobpred,2), true, ...
      size(catprobpred,1), size(catprobpred,2)));
    outs.survey = sqrt(1/C *sumsqr( ...
      ( sum(catbinpred, 2) - sum(cat_te_true, 2) ) / size(cat_te_true, 2)));
  
  elseif strcmpi(qualityMetric, 'frac_survey')
  
    outs.frac_survey = sqrt(1/C *sumsqr( ...
      ( sum(catprobpred, 2) - sum(cat_te_true, 2) ) / size(cat_te_true, 2)));
  
  end
end

varargout = struct2cell(outs);

end

