function [single_image] = compact_canvas(V, dims, nbrowcol, widths)

nb_pics = size(V, 2);

graycolor = mean([min(V(:)), max(V(:))]);

if nargin<3
  nrows = ceil(sqrt(nb_pics(1)));
  ncols = ceil(sqrt(nb_pics(1)));
else
  nrows = nbrowcol(1);
  ncols = nbrowcol(2);
end

default widths = 1;

dim1 = dims(1);
dim2 = dims(2);

% pad graycol in the end
V = V(:);
V(numel(V)+1 : dim1*dim2*nrows*ncols ) = graycolor;

V = reshape(V, dim1, dim2, ncols, nrows);
% draw grid


single_image = graycolor * ones((dim1+2*widths),(dim2+2*widths),nrows,ncols);
for i=1:ncols
  for j=1:nrows
    single_image(:,:,j,i) = [
      ones(1*widths,dim2+2*widths)*graycolor; 
      ones(dim1,1*widths)*graycolor, V(:,:,i,j),  ones(dim1,1*widths)*graycolor;
      ones(1*widths,dim2+2*widths)*graycolor ];
  end
end

single_image = permute(single_image, [1 3 2 4]);
single_image = reshape(single_image, [(dim1+2*widths)*nrows, (dim2+2*widths)*ncols]);

