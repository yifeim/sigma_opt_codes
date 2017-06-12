function [results] = structarray2cellstructarray(results)

if ~isstruct(results)
  warning('wrong type input. expecting structarray. do nothing.');
else
  for j=1:length(results)
    fmtd_results{j} = results(j);
  end
  results = fmtd_results;
end

end
