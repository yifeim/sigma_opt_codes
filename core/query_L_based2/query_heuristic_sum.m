function [queries, greedyobjs] = query_heuristic_sum(L,opts)

if nargin<2, opts=struct(); end

queryLen = get_option(opts,'queryLen',50);
queries = get_option(opts,'queries',[]);

if isempty(queries)
  [queries(1), greedyobjs(1)] = heuristic_sum([],L,opts);
end

disp([queries(:), greedyobjs(:)]);

for i=length(queries)+1:queryLen
  
  unlabeled = setdiff(1:length(L), queries);
  
  C = inv(L(unlabeled, unlabeled));
  [queryid, thisgreedyobj] = heuristic_sum(C, [], opts);
  queries(i) = unlabeled(queryid);
  greedyobjs(i) = thisgreedyobj;
  
  disp([queries(i), greedyobjs(i)]);
end
