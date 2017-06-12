function [hcls,h_heurs] = vis_query_blackwhite(Laplacian, gnd, nodepos, shownumber, q, t)

default gnd=ones(1,size(Laplacian,1));
default shownumber = true;

% figure(4);
clf;
hold on
for i=1:size(nodepos,1)
  for j=1:size(nodepos,1)
    if Laplacian(i,j)>=0, continue; end;
    plot([nodepos(i,1), nodepos(j,1)], [nodepos(i,2), nodepos(j,2)], ...
      'color',[.5 .5 .5], ...
      'linewidth',10*-Laplacian(i,j)/max(max(-Laplacian)));
  end
end

% for i=1:size(nodepos,1)
%   plot(nodepos(i,1), nodepos(i,2), 'ko', 'markersize',15);
%   if shownumber
%     text(nodepos(i,1), nodepos(i,2), num2str(i));
%   end
% end

hcls = nan(size(unique(gnd)));

clr = {'m','g','c','y'};
shape = {'o','x','+'};
for i=1:size(nodepos,1)
  plot(nodepos(i,1), nodepos(i,2), 's', 'markersize',20, ...
    'markerfacecolor',clr{gnd(i)}, 'markeredgecolor',clr{gnd(i)});
  hcls(gnd(i)) = ...
    plot(nodepos(i,1), nodepos(i,2), ['k',shape{gnd(i)}], ...
    'markersize',20, 'linewidth', 2);%,...
%     'markerfacecolor','k');%, 'markeredgecolor',clr{gnd(i)});
  if shownumber
    text(nodepos(i,1), nodepos(i,2), sprintf('  %d',i),'fontsize',30);
  end
end

h_heurs = nan(size(q));
qshape = {'s','v','h'};
if exist('q') && ~isempty(q)
  if ~iscell(q), q={q}; end
  for i=1:length(q)
    for j=1:length(q{i})
      
      h_heurs(i) = ...
        ...        plot(randn(1)*.005+nodepos(q{i}(j),1), randn(1)*.005+nodepos(q{i}(j),2), ...
        plot( nodepos(q{i}(j),1),  nodepos(q{i}(j),2), ...
        ['k',qshape{i}], ...
        'markersize', 50 , 'linewidth', 3);
      
%       text(nodepos(q{i}(j),1), nodepos(q{i}(j),2), num2str(q{i}(j)));
    end
  end
end
    
if exist('t') && ~isempty(t)
  plot(nodepos(t,1), nodepos(t,2), 'ks','markersize',10,'markerfacecolor','k');
  for j=1:length(t)
    text(nodepos(t(j),1), nodepos(t(j),2), num2str(t(j)));
  end
end

set(title(sprintf(['subgraph of %d nodes, black: test nodes; ' ...
   'r:survey; b:trace; g:eer'], length(gnd))), ...
   'fontsize',14);
