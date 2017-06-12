function [] = vizEmphGephi(A, catlabs, emph, opts)

% data
labels   = cat2nomlab( catlabs );
num_class = size(catlabs, 1);
num_nodes = size(A, 1);


% load format
formats.data = dlmread('position.gdf',',',[1,0,length(A),5]);
[~, ind] = sort(formats.data(:,1), 'ascend');
formats.data = formats.data(ind, :);

formats.ids    = formats.data(:,1);
formats.widths = formats.data(:,3);
formats.x      = formats.data(:,5);
formats.y      = formats.data(:,6);

% options
if nargin<4, opts = struct('dummy',0); end
filename = get_option(opts,'filename','tmp_graph.gdf');
% colormap = get_option(opts, 'colormap', {...
%   [55,126,184], [77,175,74], [152,78,163],[255,127,1] });
if num_class <= 9 
  colormap = get_option(opts, 'colormap', {...
    [228 26 28], [55 126 184], [77 175 74], [152 78 163], [255 127 0], ...
    [255 255 51], [166 86 40], [247 129 191], [153 153 153]  });
elseif num_class <= 11 % up to 11
  colormap = get_option(opts, 'colormap', {...
    [166 206 227], [31 120 180], [178 223 138], [51 160 44], [251 154 153], ...
    [227 26 28], [253 191 111], [255 127 0], [202 178 214], [106 61 154], ...
    [255 255 153] });
else
  s = rng;
  rng(0);
  colormap = get_option(opts, 'colormap', ...
    num2cell(randi([0,255], [num_class,3]), 2)');
  rng(s);
end

% where to save the file
fid = fopen(filename, 'w');


% first the nodes 
fprintf(fid, ['nodedef>name VARCHAR,class VARCHAR,label VARCHAR,' ...
  'color VARCHAR,width DOUBLE,x DOUBLE,y DOUBLE\n']);

% name, class, label, color, width, x, y
for i = 1:length(emph)
  id = emph(i);
  fprintf(fid, '%i,''%i'',''%i'',''%i,%i,%i'',%i,%i,%i\n', ...
    id, double(labels(id)), [i], colormap{labels(id)}, formats.widths(id), ...
    formats.x(id), formats.y(id));
end
for id = comple(emph, length(A))
  fprintf(fid, '%i,''%i'',''0'',''%i,%i,%i'',%i,%i,%i\n', ...
    id, double(labels(id)),      colormap{labels(id)}, formats.widths(id), ...
    formats.x(id), formats.y(id));
end

% find edges in graph
[to_ind, from_ind] = find(A .* triu(ones(num_nodes)));
num_edges = numel(to_ind);

% then come the edges
fprintf(fid, 'edgedef>node1 VARCHAR,node2 VARCHAR,weight DOUBLE,directed BOOLEAN\n');
for i = 1:num_edges
  fprintf(fid, '%i,%i,%.1f,false\n', ...
    to_ind(i), from_ind(i), A(to_ind(i), from_ind(i)));
end

fclose(fid);
