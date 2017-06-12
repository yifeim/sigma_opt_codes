
function [h] = myplotcurves_vs(accuracies, displaySizes, method)

colormap = { ...
  [228 26 28], [55 126 184], [77 175 74], [152 78 163], [255 127 0], ...
    [255 255 51], [166 86 40], [247 129 191], [153 153 153] };

switch method
      case {'sum','sopt'},  stylestr='ks'; styleSpecs={'MarkerSize',8};
      case 'rand', stylestr='kx'; styleSpecs={'linewidth',2,'MarkerSize',10};
      case 'eer',  stylestr='k*'; styleSpecs={'LineWidth',1,'MarkerSize',8};
      case 'cheat', stylestr='ko'; styleSpecs={'MarkerSize',8};
      case 'minbe', stylestr='g+'; styleSpecs={'MarkerSize',8};
      case 'maxbe', stylestr='r+'; styleSpecs={'MarkerSize',8};
      case 'loglike', stylestr='b+'; styleSpecs={'MarkerSize',8};
      case 'ep_5', stylestr='m^'; styleSpecs={'MarkerSize',12};
      case 'ep1', stylestr='k^'; styleSpecs={'MarkerSize',8};
      case 'ep1_5', stylestr='g^'; styleSpecs={'MarkerSize',12};
      case {'tr','vopt','ep2'}, stylestr='kv'; styleSpecs={'LineWidth',1,'MarkerSize',8};
      case {'unc'}, stylestr='k+'; styleSpecs={'markersize',8};
      case {'mig'}, stylestr='ch'; styleSpecs={'markersize',8};
      case {'ig'}, stylestr='bp'; styleSpecs={'markersize',8};
      case {'sfo_mig_s'}, stylestr='m.'; styleSpecs={'markersize',8};
      case {'sfo_mig_g'}, stylestr='mo'; styleSpecs={'markersize',8};
      otherwise, stylestr='y+'; styleSpecs={'MarkerSize',15};

end
h=myerrorbar(accuracies, displaySizes, stylestr, styleSpecs);
end

function [h] = myerrorbar(accuracies, displaySizes, stylestr, styleSpecs)

errorbar(1:size(accuracies, 1), mean(accuracies,2), ...
  sqrt(1/size(accuracies, 2))*std(accuracies,1,2),'color',[.7 .7 .7]);

mean_accuracies = mean(accuracies, 2);

h = plot(displaySizes, mean_accuracies(displaySizes), stylestr,...
  styleSpecs{:});

end
