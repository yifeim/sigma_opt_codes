function [listofHeurs, varargout] = meanresults( ...
  rgrsn_evals, listofHeurs, listofQualities, opts)

default opts = struct();

nb_fold = length(rgrsn_evals);

if ~iscell(rgrsn_evals), rgrsn_evals = {rgrsn_evals}; end

default listofHeurs = setdiff( fieldnames(rgrsn_evals{1}), {'seed','test'} );
if ~iscell(listofHeurs), listofHeurs = {listofHeurs}; end 

default listofQualities = fieldnames(rgrsn_evals{1}.(listofHeurs{1}));
if ~iscell(listofQualities), listofQualities = {listofQualities}; end

queryLen = get_option(opts, 'queryLen', length(rgrsn_evals{1}.(listofHeurs{1})));

for qitr=1:length(listofQualities)
  for hitr = 1:length(listofHeurs)
    meanthisQ(hitr, :) = arrayfun( ...
      @(c) themeanfun(rgrsn_evals, listofHeurs{hitr}, listofQualities{qitr}, c), ...
      1:queryLen);
  end
  varargout{qitr} = meanthisQ;
end

end

function [number] = themeanfun(rgrsn_evals, hname, qname, c)
number = mean(cellfun(@(r) r.(hname)(c).(qname), rgrsn_evals));
end
