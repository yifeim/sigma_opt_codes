function [h] = myplotshort(res, listofHeurs, querymetric, opts)



default opts = struct();

legends = get_option(opts,'legends',listofHeurs);
location = get_option(opts,'location','southeast');
fontsize = get_option(opts,'fontsize',16);
displaySizes = get_option(opts,'displaySizes',1:3:length([res(1).curves.(querymetric)]));
labels = get_option(opts,'labels',...
  {'query budget', [querymetric, ' on unlabeled' ], '' });




%% begin plotting

hold on
h = [];

% plot the canvas
for mitr=1:length(listofHeurs)
  
  % pin point the ids
  todisplay = [];
  for id=1:numel(res)
    if strcmpi(res(id).heur, listofHeurs{mitr})
      todisplay(:, end+1) = [res(id).curves.(querymetric)];
    end
  end
  
  plot_accu_mn_se(mean(todisplay,2), se(todisplay,[],2), {listofHeurs{mitr}, '', 10}, false);
  
  %   h(end+1)=myplotcurves_vs(todisplay, displaySizes, listofHeurs{mitr});
  disp([num2str(size(todisplay,2)), listofHeurs{mitr}])
end

axis_set = get_option(opts,'axis',axis);


% plot the base
for mitr=1:length(listofHeurs)
  
  % pin point the ids
  todisplay = [];
  for id=1:numel(res)
    if strcmpi(res(id).heur, listofHeurs{mitr})
      todisplay(:, end+1) = [res(id).curves.(querymetric)];
    end
  end
  
  plot_accu_mn_se(mean(todisplay,2), se(todisplay,[],2), {listofHeurs{mitr}, '', 10}, true);
  
  %   h(end+1)=myplotcurves_vs(todisplay, displaySizes, listofHeurs{mitr});
  disp([num2str(size(todisplay,2)), listofHeurs{mitr}])
end


% plot the curve
for mitr=1:length(listofHeurs)
  
  % pin point the ids
  todisplay = [];
  for id=1:numel(res)
    if strcmpi(res(id).heur, listofHeurs{mitr})
      todisplay(:, end+1) = [res(id).curves.(querymetric)];
    end
  end
  
  h(end+1) = plot_accu_mn_se(mean(todisplay,2), se(todisplay,[],2), {listofHeurs{mitr}, '', 10}, false);
  
  %   h(end+1)=myplotcurves_vs(todisplay, displaySizes, listofHeurs{mitr});
  disp([num2str(size(todisplay,2)), listofHeurs{mitr}])
end

set(title(querymetric),'fontsize',14,'interpreter','none');
grid on


set(gca,'fontsize',fontsize);
set(legend(h,legends),...
  'location',location,'fontsize',fontsize);
title(labels{3},'fontsize',fontsize);
xlabel(labels{1},'fontsize',fontsize+2);
ylabel(labels{2},'fontsize',fontsize+2);
axis(axis_set);


% function [h] = myplotshort(res, listofHeurs, querymetric, opts)
% 
% 
% 
% default opts = struct();
% 
% legends = get_option(opts,'legends',listofHeurs);
% location = get_option(opts,'location','southeast');
% fontsize = get_option(opts,'fontsize',16);
% displaySizes = get_option(opts,'displaySizes',1:3:length([res(1).curves.(querymetric)]));
% labels = get_option(opts,'labels',...
%   {'query budget', [querymetric, ' on unlabeled' ], '' });
% axis_set = get_option(opts,'axis',[]);
% 
% 
% %% begin plotting
% 
% hold on
% h = [];
% 
% for mitr=1:length(listofHeurs)
%   
%   % pin point the ids
%   todisplay = [];
%   for id=1:numel(res)
%     if strcmpi(res(id).heur, listofHeurs{mitr})
%       todisplay(:, end+1) = [res(id).curves.(querymetric)];
%     end
%   end
%   
%   h(end+1)=myplotcurves_vs(todisplay, displaySizes, listofHeurs{mitr});
%   disp([num2str(size(todisplay,2)), listofHeurs{mitr}])
% end
% 
% set(title(querymetric),'fontsize',14,'interpreter','none');
% grid on
% 
% 
% set(gca,'fontsize',fontsize);
% set(legend(h,legends),...
%   'location',location,'fontsize',fontsize);
% title(labels{3},'fontsize',fontsize);
% xlabel(labels{1},'fontsize',fontsize+2);
% ylabel(labels{2},'fontsize',fontsize+2);
% axis(axis_set);
% 
