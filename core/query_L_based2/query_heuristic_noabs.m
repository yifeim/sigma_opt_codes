function [queries, greedyobjs] = query_heuristic_noabs( ...
  K,y,opts)

if nargin<3, opts=struct(); end

queryLen = get_option(opts,'queryLen',50);

queries = get_option(opts,'queries',[]);
greedyobjs = get_option(opts,'greedyobjs',[]);


for i=length(queries)+1:queryLen
  [queries(i,1), greedyobjs(i,1)] = heuristic_noabs(...
    K, queries, y(queries), opts);

  clk = clock;
  disp([i, queries(i), greedyobjs(i), clk(4:5)]);
  
end

