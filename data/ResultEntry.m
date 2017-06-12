classdef ResultEntry
  properties
    sid = 0;
    heur = '';
    queryseq = [];
    greedyObjs = [];
    curves = struct('accuracy', []);
    
    misc  = {};
    
    seed = 0;
    backgnd = struct();
    note = {};
    timeMeasures = struct();

  end
  methods
    
%     function obj = ResultEntry(sid, heur, seed)
%       obj.sid      = sid;
%       obj.heur     = heur;
%       obj.queryseq = seed;
%     end
    
    function obj = compute_Curves(obj, listofQualitymetrics, Laplacian, ...
        catlabs)
      for i=1:numel(obj)
        obj(i).curves = GRF_prediction_eval( ...
          listofQualitymetrics, Laplacian, obj(i).queryseq, catlabs, ...
          [], 1:length(obj(i).queryseq), 1, false, 0);
      end
%       function [outs, varargout] ...
%   = GRF_prediction_eval(  ...
%   listOfQMetrics, Laplacian, querySeq, catlabs, testind, querySizes, ...
%   beta, sparsifyLaplacian, prior)
    end
    
    function show(obj) 
      disp(arrayfun(@(x) length(x.queryseq), obj));
    end
    
  end
end

