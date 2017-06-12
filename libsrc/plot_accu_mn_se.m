function [h] = plot_accu_mn_se(mean_accu, se_accu, specs, errbar, opts)

default opts = struct();

colormap = get_option(opts, 'colormap', {...
  [228 26 28], [55 126 184], [77 175 74], [152 78 163], [255 127 0], ...
  [255 255 51], [166 86 40], [247 129 191], [153 153 153]  });

if iscell(specs)
  
  switch(specs{1})
    case {'sum', 'sopt'}, marker_style = {'s','color', colormap{1}/255}; %r
    case {'tr', 'vopt'}, marker_style = {'v','color', colormap{2}/255}; %b
    case 'rand', marker_style = {'x','color', colormap{3}/255}; %g
      
    case 'eer', marker_style = {'*','color',  colormap{4}/255};
    case 'mig', marker_style = {'h', 'color', colormap{6}/255};
    case 'ig',  marker_style = {'h', 'color', colormap{8}/255};
    case 'unc',  marker_style = {'+','color', colormap{7}/255};
  end
  switch(specs{1})
    case {'sum','tr', 'rand'}, line_style = ['-', marker_style(2:end)];
    otherwise, line_style = ['-', marker_style(2:end)];
  end
  %   switch(specs{2})
  %     case 'bp', line_style = [marker_style(1), '-'];
  %     case 'sig', line_style  = [marker_style(1), '--'];
  %     otherwise, line_style = [marker_style(1), ':'];
  %   end
  
  legend_style = [[marker_style{1}, line_style{1}], marker_style(2:end)];
  
  if length(specs)>=3 && ~isempty(specs{3})
    interval = specs{3};
  else
    interval = 5;
  end
  
  
  
end

default errbar = false;

len = get_option(opts, 'len', length(mean_accu));

hold on;

h=[];

if errbar
  
%   h = plot(mean_accu(1:len), legend_style, 'linewidth', 2,'markersize',10);
  
    errorbar((1:len)', mean_accu(1:len),  se_accu(1:len), ...
      'color', [.6 .6 .6],'linewidth',2);
%   shadedErrorBar((1:len)', mean_accu(1:len),  se_accu(1:len));
  
end

plot(mean_accu(1:len), line_style{:}, 'linewidth', 2);
h=plot(1:interval:len, mean_accu(1:interval:len), marker_style{:}, 'linewidth', 2,'markersize',15);

hold off;
