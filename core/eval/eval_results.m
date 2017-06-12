function [evaled_results] = eval_results( ...
  results, listofQualitymetrics, Laplacian, catlabs, prior)


default prior=0;
if iscell(results), results = cellstructarray2structarray(results); end

fdns = fieldnames(results);
fdns = fdns(~strcmpi(fdns,'seed') & ~strcmpi(fdns,'test'));
listofHeurs = fdns;

displaySizes=1:length(results(1).(fdns{1}));

% results{j}.sum(n).query -> results{j}.sum(n).accuracy
% evaluate
parfor j=1:length(results)
% for j=1:length(results)
  for h = 1:length(listofHeurs)
    if isempty(listofQualitymetrics)
      evaled_results{j}.(listofHeurs{h}) = repmat(struct(), 1, max(displaySizes));
    else
      evaled_results{j}.(listofHeurs{h}) = GRF_prediction_eval(...
        listofQualitymetrics, Laplacian, [results(j).(listofHeurs{h}).query], ...
        catlabs, [], displaySizes, 1, false, prior)
    end
  end
end

% merge with existing entries (e.g. query)
for j = 1:length(results)
  for h = 1:length(listofHeurs)
    qm_names = fieldnames(evaled_results{j}.(listofHeurs{h}));
    qm_names_old = fieldnames(results(j).(listofHeurs{h}));
    mkup_qm_names = setdiff(qm_names_old, qm_names);
    for q=1:length(mkup_qm_names)
      [evaled_results{j}.(listofHeurs{h}).(mkup_qm_names{q})] = ...
        results(j).(listofHeurs{h}).(mkup_qm_names{q});
    end
  end
end

evaled_results = cellstructarray2structarray(evaled_results);
% for seed and test fields
evaled_results = mergeresults(evaled_results, results);

end
