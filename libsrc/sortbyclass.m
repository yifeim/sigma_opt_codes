function [features, labelsorcatlabs, note] = sortbyclass( ...
  features, labelsorcatlabs, nb_instances)

% --------------------------- sanity check ------------------------------

default nb_instances = size(labelsorcatlabs, 2);

assert(  size(features,2) == nb_instances  );
assert(  size(labelsorcatlabs,2)   == nb_instances  );

if size(labelsorcatlabs, 1) > 1,
  numlabels2sort = cat2nomlab(labelsorcatlabs);
end

% --------------------------- order by class ---------------------



% order according to classes
[~, old_ids] = sort(double(numlabels2sort), 'ascend');
features = features(:, old_ids);
labelsorcatlabs = labelsorcatlabs(:, old_ids);

note = ' sort indices such that labels appear in ascending order ';

% 
% 
% % --------------------------- organize ------------------------------
% % sort classes
% catlabs = cellfun(@(c) strcmp(node_class, c), classes, 'uniformoutput',false);
% catlabs = cell2mat(catlabs)';
% 
% [~, logger_cls_ind] = sort(sum(catlabs,2), 'descend');
% classes = classes(logger_cls_ind);
% catlabs = catlabs(logger_cls_ind, :);
% 
% note{end+1} = 'sort CLASSES. logger_cls_ind';
% 
% % find largestgraphconncomp
% 
% [A, catlabs, logger_connpos, node_names, node_class] = ...
%   largestgraphconncomp(A, catlabs, node_names, node_class);
% note{end+1} = 'largestgraphconncomp. logger_connpos';
% 
% 
% % sort nodes 
% [logger_node_ind, catlabs, A, node_names, node_class] = ...
%   sortnodes(catlabs, A, node_names, node_class);
