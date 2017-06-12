function [queries, greedyobjs] = query_heuristic_trace_active_new(K,y,opts)

if nargin<3, opts=struct(); end

queryLen = get_option(opts,'queryLen',50);

queries = get_option(opts,'queries',[]);
greedyobjs = get_option(opts,'greedyobjs',[]);


for i=length(queries)+1:queryLen
  tic;
  [queries(i,1), greedyobjs(i,1), objs2min] = heuristic_trace_active_new(...
    K, queries, y(queries), opts);

%   if i==2
%     keyboard;
%   end

  roundtime = toc;
  clk = clock;
  disp([i, queries(i), greedyobjs(i), roundtime, clk(4:5)]);
  
end

