function [query, greedyObj, objs2min] = heuristic_trace(C,L,opts)


if nargin<3, opts=struct(); end;

if isempty(C)
  [~,sortid] = sort(diag(L),'descend');
  
  firstQuerySampleSize = get_option(opts, 'firstQuerySampleSize', 1);
  
  objs2min = nan(1, length(L));
  parfor i=1:min(firstQuerySampleSize, length(L))
    objs2min(i) = trace(inv(L(...
      sortid([1:i-1, i+1:end]), sortid([1:i-1, i+1:end]) ...
      )));
  end
  
  [~,queryid] = min(objs2min);
  query = sortid(queryid);
  greedyObj = objs2min(queryid);
else %use C
  old_obj = trace(C);
  
  objs2min = nan(1, length(C));
  for i=1:length(C)
    objs2min(i) = old_obj - sum( C(:,i).^2 / C(i,i) );
  end
  
  [~,query] = min(objs2min);
  greedyObj = objs2min(query);
  
end
