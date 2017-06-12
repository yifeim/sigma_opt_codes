function [outs, varargout] ...
  = GRF_prediction_eval(  ...
  listOfQMetrics, Laplacian, querySeq, catlabs, testind, querySizes, ...
  beta, sparsifyLaplacian, prior)
% 'accuracy' 'bin_entropy' 'joint_loglike' 'survey' 'frac_survey'

querySizes = querySizes(querySizes<=length(querySeq));

if ~iscell(listOfQMetrics), listOfQMetrics = {listOfQMetrics}; end
outs = struct();
for i=1:length(listOfQMetrics), outs.(listOfQMetrics{i})=nan; end
outs(1:max(querySizes)) = outs;

tic;

default prior=0;

default beta=1;

default testind = true(size(Laplacian, 1), 1);
if ~islogical(testind)
  testind = logical(full(sparse(testind, 1, 1, size(Laplacian, 1), 1)));
end

if (length(testind) ~= size(Laplacian, 1)) || (size(catlabs,2) ~=size(Laplacian, 1))
  warning('labels or testind length mismatch'); 
end

default  querySizes = 1:length(querySeq);

default sparsifyLaplacian = (nnz(Laplacian) / numel(Laplacian) < 5e-3);
if sparsifyLaplacian,  Laplacian = sparse(Laplacian);  end

unlab_set = comple(querySeq(1:querySizes(1)), size(Laplacian,1));

invLuu = inv(Laplacian(unlab_set, unlab_set));

for querySize = querySizes
  labed_set      = querySeq(1:querySize);
  lastUnlab_set  = unlab_set;
  unlab_set      = setdiff(1: size(Laplacian,1), labed_set); 
  
  testInUnlab = testind(unlab_set);
  cat_te_true = catlabs(:, intersect(unlab_set, find(testind)));
  
  lastC = invLuu;
  newly_labed = ~ismember(lastUnlab_set, unlab_set);
  invLuu = lastC - ...
    lastC(:,newly_labed)/lastC(newly_labed, newly_labed)*lastC(newly_labed,:);
  invLuu = invLuu(~newly_labed, ~newly_labed);
  
  %   assert(mateq(invLuu, inv(Laplacian(unlab_set,unlab_set))));
  %   Luu = Laplacian(unlab_set, unlab_set);
  
  if all(testInUnlab)
    outs(querySize) = metric_function( listOfQMetrics, ...
      - catlabs(:, labed_set) * Laplacian(labed_set, unlab_set) * invLuu, ...
      cat_te_true, invLuu, prior);
  else
    
    Llu = Laplacian(labed_set, unlab_set);
    catoutputs = -catlabs(:, labed_set)*Llu * invLuu;
    catprobpred = catoutputs(:, testInUnlab);
    
    Covuu = beta.* invLuu;
    outs(querySize) = metric_function( listOfQMetrics, ...
      catprobpred, cat_te_true, Covuu(testInUnlab, testInUnlab), prior );
    
  end
  
  %   invCov = 1/beta * Luu;
  %   invCov = invCov - ...
  %     invCov(:, ~testInUnlab) / invCov(~testInUnlab, ~testInUnlab) * invCov(~testInUnlab, :);
  %   invCovtt = invCov(testInUnlab, testInUnlab);
  %
  % %   eyetest = sparse(1:nnz(testInUnlab), find(testInUnlab), 1, ...
  % %     nnz(testInUnlab), length(testInUnlab));
  % %   Covtt = beta * eyetest / Luu * eyetest';
  % %   invCovtt2 = inv(Covtt);
  % %   assert(mateq(invCovtt, invCovtt2));
  %
  %   outs(querySize) = prediction_quality_basic(...
  %     listOfQMetrics, cat_te_true, catprobpred, invCovtt);
  
  if isfield(outs,'accuracy')
    outs(querySize).accuracy = ...
      outs(querySize).accuracy*nnz(testind(unlab_set)) / nnz(testind) + ...
      nnz(testind(labed_set)) / nnz(testind);
  end
end

toc;
disp(['evaluation done',num2str(round(clock))]);

for i=1:length(listOfQMetrics), varargout{i} = [outs.(listOfQMetrics{i})]; end
