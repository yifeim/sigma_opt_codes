function [results] =cellstructarray2structarray(results)

if ~iscell(results)
  warning('not cell array. do nothing.');
else
  for j=1:length(results)
    fmtd_results(j) = results{j};
  end
  results = fmtd_results;
end

end
