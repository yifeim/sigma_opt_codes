function [] = make4gephi(A,opts)

if nargin<2, opts = struct('dummy',0); end
filename = get_option(opts,'filename','tmp_graph.gdf');
weighted = get_option(opts, 'weighted', false);
colormap = get_option(opts, 'colormap', floor(255 * lbmap(1000, 'blue')));
emph     = get_option(opts, 'emph', []);
if isvector(emph)
  emph = [emph(:), repmat([255 1 1], length(emph), 1)];
end

num_nodes = size(A, 1);

% 0<y<1
y = get_option(opts, 'y', ones(1, num_nodes));
labels = get_option(opts, 'labels', num2cell(num2str((1:num_nodes)'),2));

if ~weighted, A = logical(A); A = A - diag(diag(A)); end


% where to save the file
fid = fopen(filename, 'w');

% first the nodes
fprintf(fid, 'nodedef>name VARCHAR,label VARCHAR,color VARCHAR\n');
for i = 1:num_nodes
  color = colormap( ceil(eps + y(1, i) * 999) , :);
  
  if isempty(emph)
    emph_id = [];
  else
    emph_id = find(emph(:,1)==i);
  end
  if isempty(emph_id)
    fprintf(fid, '%i,''%s'',''%i,%i,%i''\n', i, labels{i}, color(1), color(2), color(3));
  else
    fprintf(fid, '%i,''%s'',''%i,%i,%i''\n', i, labels{i}, emph(emph_id,2:end));
  end
end

% find edges in graph
[to_ind, from_ind] = find(A .* triu(ones(num_nodes)));
num_edges = numel(to_ind);

% then come the edges
fprintf(fid, 'edgedef>node1 VARCHAR,node2 VARCHAR,weight DOUBLE\n');
for i = 1:num_edges
  fprintf(fid, '%i,%i,%.3f\n', ...
    to_ind(i), from_ind(i), A(to_ind(i), from_ind(i)));
end

fclose(fid);
