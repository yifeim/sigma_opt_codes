function [] = make_wikipedia_graph(A,y,opts)

if nargin<3, opts = struct(); end
filename = get_option(opts,'filename','~/tmp/wiki_graph.gdf');
% emph = get_option(opts, 'emph', []);
emph = get_option(opts, 'emph', [ ...
  3273 255 1 1 ; ...
  5025 255 1 1; ...
  3993 255 1 1; ...
  1808 255 1 1; ...
  1545 255 1 1 ; ...
  5031 255 1 1; ...
  5183 255 1 1; ...
  819 255 1 1]);
weighted = get_option(opts, 'weighted', false);

if ~weighted, A = logical(A); A = A - diag(diag(A)); end
num_nodes = size(A, 1);

% find edges in graph
[to_ind, from_ind] = find(A .* triu(ones(num_nodes)));
num_edges = numel(to_ind);

% grab a nice colormap, can be anything
c = lbmap(1000, 'blue');
% gephi wants colors in [0, 255]
c = floor(c * 255);

% where to save the file
fid = fopen(filename, 'w');

% nodes come first
% node header
fprintf(fid, 'nodedef>name VARCHAR,color VARCHAR\n');
% node information.  first the name, then the color in the format 'r,g,b'
for i = 1:num_nodes
  % scale the y value (in [0, 1]) to an integer in the range [1, 1000]
  color_ind = ceil(eps + y(1, i) * 999);
  % get corresponding color from colormap
  color = c(color_ind, :);
  % print node line to file
  emph_id = find(emph(:,1)==i);
  if isempty(emph_id)
    fprintf(fid, '%i,''%i,%i,%i''\n', i, color(1), color(2), color(3));
  else
    fprintf(fid, '%i,''%i,%i,%i''\n', emph(emph_id,:));
  end
end

% then come the edges
% edge header
fprintf(fid, 'edgedef>node1 VARCHAR,node2 VARCHAR\n');
for i = 1:num_edges
  % print the edge line to a file, just from,to
  fprintf(fid, '%i,%i\n', to_ind(i), from_ind(i));
end

% close file
fclose(fid);
