function [outs, varargout] = graph_prediction( ...
  trainset, testset, A, catlabs, listOfQMetrics, opts)

default opts = struct();
default testset = setdiff(1:length(A), trainset);

test_on_labeled = get_option(opts,'test_on_labeled', true);

pred_us = catlabs;
pred_us(:, testset) = label_propagation(A, catlabs(:, trainset)', trainset, testset, opts)';

if test_on_labeled
  eval_set = 1:length(A);
else
  eval_set = testset;
end

if nargin<=4 || isempty(listOfQMetrics)
  outs = pred_us;
else
  [outs, varargout] = metric_function( ...
    listOfQMetrics, pred_us(:,eval_set), catlabs(:, eval_set));

end
