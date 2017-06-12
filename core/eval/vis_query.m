function [] = vis_query(Laplacian, gnd, nodepos, shownumber, q, t)

default gnd=ones(1,size(Laplacian,1));
default shownumber = true;

figure(4);
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

clr = {'m','g','c','y'};
for i=1:size(nodepos,1)
  plot(nodepos(i,1), nodepos(i,2), 's', 'markersize',10, ...
    'markerfacecolor',clr{gnd(i)}, 'markeredgecolor',clr{gnd(i)});
  if shownumber
    text(nodepos(i,1), nodepos(i,2), num2str(i));
  end
end

qclr = {'r','b','g'};
if exist('q') && ~isempty(q)
  if ~iscell(q), q={q}; end
  for i=1:length(q)
    plot(randn(1)*.005+nodepos(q{i}(1),1), randn(1)*.005+nodepos(q{i}(1),2), ...
      [qclr{i},'s'], ...
      'markersize',15, 'linewidth', 3);
    plot(randn(1)*.005+nodepos(q{i}(2:end),1), randn(1)*.005+nodepos(q{i}(2:end),2), ...
      [qclr{i},'o'], ...
      'markersize',15, 'linewidth', 3);
    for j=1:length(q{i})
      text(nodepos(q{i}(j),1), nodepos(q{i}(j),2), num2str(q{i}(j)));
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
