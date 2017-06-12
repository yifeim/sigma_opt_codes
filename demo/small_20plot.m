% small_DBLP15
% 
% abalone_ard.mat		     citeseer.mat	     DBLP20_v2.mat
% abalone.csv		     cora.mat		     DBLP268_accuracy.pdf
% abalone_hyperparameters.mat  DBLP14.mat		     DBLP268_graph.pdf
% abalone.mat		     DBLP15.mat		     DBLP268nodes.mat
% alldatasets.mat		     DBLP20_v1_accuracy.pdf  DBLP.mat
% citeseer198nodes.mat	     DBLP20_v1_graph.pdf     grasping.mat
% citeseer615.mat		     DBLP20_v1.mat	     images.mat
% citeseer615nodes.fig	     DBLP20_v2_accuracy.pdf  test_DBLP.mat
% citeseer733nodes.mat	     DBLP20_v2_graph.pdf     wiki_program.mat

load DBLP20_v1

catlabs = accumarray( [gnd(:), (1:length(gnd))'], 1);

listofHeurs = {'ep2','ep1'}
opts = struct('queryLen',10);


nodepos(19,:) = [.2, .2];
nodepos(:,2) = .8*nodepos(:,2);
% 
% comp_nodepos = complex(nodepos(:,1), nodepos(:,2));
% comp_nodepos = comp_nodepos * exp(-1i*pi/25);
% nodepos = [real(comp_nodepos), imag(comp_nodepos)];


for hitr=1:length(listofHeurs)
  
  [thisqueries, thisgreedyObjs] = easy_active_query_clsfctn_rgrsn( ...
    listofHeurs{hitr}, Laplacian, catlabs, 1, 0, opts);
  thisresult.(listofHeurs{hitr}) = struct( ...
    'query',num2cell(thisqueries), 'greedyObj',num2cell(thisgreedyObjs));
  
end

[hcls, hheurs] = vis_query_blackwhite(Laplacian, gnd, nodepos, false, {...
  [thisresult.ep1(1:3).query], [thisresult.ep2(1:3).query]});
  %[1 3 12],[1 20 19]});
  
hdummy = plot(0.5,0.5,'w.');
hl = legend([hcls,hdummy,hheurs(1),hdummy,hheurs(2)], '  class 1','  class 2','  class 3', ...
  ' ','  \Sigma-optimality', ' ','  V-optimality',...
  ...sprintf('\n  \\Sigma-optimality\n\n'), sprintf('\n  V-optimality\n\n'), ...
  'location','best');
set(hl,'box','off');

hold on

title('');
axis on 
axis equal
axis off
% 
% set(gcf,'paperpositionmode','manual');
% saveas(gcf,'demo_20DBLP.pdf');
% 
% 
% template_d = @(x) sprintf([...
%   'pdfcrop ../plots/demo_%s.pdf;' ...
%   'mv ../plots/demo_%s-crop.pdf ../plots/demo_%s.pdf'...
%   ], x,x,x);
% 
% system( template_d('20DBLP') );
% 
