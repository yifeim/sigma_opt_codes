function [outs] = ...
  easy_curves(listofHeurs, listofQualitymetrics, ...
  Laplacian, catlabs, isrgrsn, opts) %testLen, test_bfs, ...
% seedLen, nb_fold, queryLen, seed, test, fig_id, priorMean)

try

default opts = struct();
nb_fold = get_option(opts, 'nb_fold', 12);
seedLen = get_option(opts, 'seedLen', 1);
queryLen = get_option(opts, 'queryLen', 50);
queryLen = min(queryLen, size(catlabs,2));
fig_id   = get_option(opts, 'fig_id', 2);
priorMean = get_option(opts, 'priorMean', 0);
displaySizes = get_option(opts, 'displaySizes', 1:queryLen);
useparfor = get_option(opts, 'useparfor', true);

if ~isfield(opts, 'origCov')
  assert(size(catlabs,2)==size(Laplacian,1));
end

if ~iscell(listofHeurs), listofHeurs = {listofHeurs}; end
if ~iscell(listofQualitymetrics), 
  listofQualitymetrics={listofQualitymetrics};
end

rand('state',sum(100*clock));

if isfield(opts, 'seed') && ~isempty(opts.seed)
  seed = opts.seed;
  assert(size(seed,2)==nb_fold);
else
  for j=1:nb_fold
    seed(:,j) = randsample(1:size(catlabs,2), seedLen);
  end
end

for j=1:nb_fold
  outs{j} = struct('seed', seed(:,j));
end

if useparfor
  parfor j=1:nb_fold
    for hitr=1:length(listofHeurs)
      
      [thisqueries, thisgreedyObjs] = easy_active_query_clsfctn_rgrsn( ...
        listofHeurs{hitr}, Laplacian, catlabs, outs{j}.seed, isrgrsn, opts);
      outs{j}.(listofHeurs{hitr}) = struct( ...
        'query',num2cell(thisqueries), 'greedyObj',num2cell(thisgreedyObjs));
      
    end
  end
else
  for j=1:nb_fold
    for hitr=1:length(listofHeurs)
      
      [thisqueries, thisgreedyObjs] = easy_active_query_clsfctn_rgrsn( ...
        listofHeurs{hitr}, Laplacian, catlabs, outs{j}.seed, isrgrsn, opts);
      outs{j}.(listofHeurs{hitr}) = struct( ...
        'query',num2cell(thisqueries), 'greedyObj',num2cell(thisgreedyObjs));
      
    end
  end
end

outs = eval_results(outs, listofQualitymetrics, Laplacian, catlabs, priorMean);

catch le
  disp(le);
end
