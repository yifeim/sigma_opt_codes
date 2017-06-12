function [cut_matrix] = vizAlabel(A, catlabs)


% the basic
num_class = size(catlabs, 1);
num_nodes = size(catlabs, 2);


canvas_basic = 1-catlabs'*catlabs;

% sort nodes
[~, catlabs, A] = sortnodes(catlabs, A);


% cut and confusion matrix
cut_matrix = zeros(num_class);

for i=1:num_class
  for j = 1:num_class
    cut_matrix(i,j) = nnz(A(find(catlabs(i,:)==1), find(catlabs(j,:)==1)));
  end
end

confusion_matrix = diag(sum(cut_matrix)) \ cut_matrix;

% advanced canvas
canvas_advanced     = canvas_basic; 
for i=1:num_class
  for j=1:num_class
    canvas_advanced(find(catlabs(i,:)==1), find(catlabs(j,:)==1)) = ...
      1-confusion_matrix(i,j);
  end
end

% visualize canvas
canvas = canvas_advanced; 
imagesc(canvas, [-1, 1]);
colormap gray


% the map
hold on
spy(A);


% more complicated cut matrices


