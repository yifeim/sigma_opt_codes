rootfilename = mfilename;
load digits_scikit.csv;

dbstop if error;

features = digits_scikit(:, 1:64)';
classes = num2cell('0123456789');  

catlabs = digits_scikit(:, 65)';
catlabs = num2catlab(catlabs);

note0 = {};
note0{end+1} = ' load from scikit-learn.org ';

paras0             = struct();
paras0.classes     = classes;
paras0.queryLen    = 50;


res = ResultEntry.empty;

heurs = {'sopt','vopt','rand', 'mig','unc','ig'};%,'eer'};


for sid = 1:2
  
  valid_sample = false;
  while ~valid_sample
    [backgnd, thisnote] = subsample_and_graph(  features, catlabs, .7, 5, paras0, note0)
    valid_sample = graphconncomp(sparse(backgnd.sA))==1;
  end
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % utilizing the core methods with max degree
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  [deg, seed] = max(sum(full(backgnd.sA)))

  for hid = 1:length(heurs)
    res(sid, hid)             = ResultEntry();
    res(sid, hid).heur        = heurs{hid};
    res(sid, hid).seed        = seed;
    res(sid, hid).backgnd     = backgnd;
    res(sid, hid).note     = thisnote;
    
    res(sid, hid).timeMeasures.qtimestart   = clock();
  
    [res(sid, hid).queryseq, res(sid, hid).greedyObjs] = easy_queries( ...
      heurs{hid}, full(backgnd.sL0), seed, ...
      struct('queryLen', backgnd.queryLen, 'catlabs', backgnd.catlabs));
    
    res(sid, hid).timeMeasures.qtimeend = clock();
    res(sid, hid).timeMeasures.qruntime = etime( ...
      res(sid,hid).timeMeasures.qtimeend, res(sid,hid).timeMeasures.qtimestart);
    
  end
end

% keyboard;

res_accu = ResultEntry.empty;

for i=1:numel(res)
  res_accu(i) = compute_Curves(res(i), {'accuracy'}, full(res(i).backgnd.sL0), res(i).backgnd.catlabs);
end

res_accu = reshape(res_accu, size(res));

ave_runtime = arrayfun(@(r) r.timeMeasures.qruntime, res_accu);
ave_runtime = mean(ave_runtime, 1) %originally 3 i don'e know

res_frac_survey = ResultEntry.empty;

for i=1:numel(res)
  res_frac_survey(i) = compute_Curves(res(i), {'frac_survey'}, full(res(i).backgnd.sL0), res(i).backgnd.catlabs);
end

res_frac_survey = reshape(res_frac_survey, size(res));

% save([rootfilename, '.mat']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


figure(7); clf;
h2 = myplotshort(res_accu, heurs, 'accuracy');
set(gcf,'position',[440   101   413   647]);
set(legend(h2, ...
  '\Sigma-opt', 'V-opt', 'Rand','MIG','Unc','EER', 'IG'),...
  'location','southeast','fontsize',28);
xlabel(''); ylabel('');
set(gca,'fontSize',20);
set(gca,'xlim',[0 paras0.queryLen]);

% savepdf(gcf,[rootfilename, '.pdf']);



figure(8); clf;
h2 = myplotshort(res_frac_survey, heurs, 'frac_survey');
set(gcf,'position',[440   101   413   647]);
set(legend(h2, ...
  '\Sigma-opt', 'V-opt', 'Rand','MIG','Unc','EER', 'IG'),...
  'location','northeast','fontsize',28);
xlabel(''); ylabel('');
set(gca,'fontSize',20);
set(gca,'xlim',[0 paras0.queryLen]);

% savepdf(gcf,[rootfilename, '_fsurvey.pdf']);
