function [clumbersome_backgnd, note, backgnd] = subsample_and_graph( ...
  features, catlabs, sample_rate, k, backgnd, note)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% organize, sample, and construct the graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

default paras = struct();
default note = {};

% -------------------------- organize the data -------------------------

[features, catlabs, note{end+1}] = sortbyclass(features, catlabs, size(features, 2));

% -------------------------- sample the data ---------------------------

default sample_rate = .7;                  


[sample_ind, rng_seed, note{end+1}] = randsamplekeepclasses(catlabs, sample_rate);

% features = features(:, sort(sample_ind));
% catlabs  = catlabs(:, sort(sample_ind));

features = features(:, (sample_ind));
catlabs  = catlabs(:, (sample_ind));


% organize the data again
[features, catlabs, note{end+1}] = sortbyclass(features, catlabs, size(features, 2));

backgnd.sample_rate = sample_rate;
backgnd.rng_seed = rng_seed;
backgnd.sample_ind  = sample_ind;
backgnd.features   = features;
backgnd.catlabs    = catlabs;


% -------------------------- construct the graph ---------------------------

num_nodes = size(features,2);

default k = 5; 
neighbors = knnsearch(features', features', 'k', k);

selfs = repmat( (1:num_nodes)', [1, k]);
E = accumarray([selfs(:), neighbors(:)], 1, [num_nodes, num_nodes]);

A = (E + E')/2;


backgnd.k = k;

% ------------------------ organize results --------------------

clumbersome_backgnd = backgnd;

clumbersome_backgnd.sE = sparse(E);
clumbersome_backgnd.sA = sparse(A);
clumbersome_backgnd.sL0 = sparse(diag(sum(A)) - A);

end
