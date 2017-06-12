function [x, val] = lr_coord(A,y,nb_iter) 

% solves min ||Ax-y||^2, which is x = A\y 
% sparse?
% min .5 x' K x - ks' x

if nargin<3, nb_iter = 100000; end

x = zeros(size(A,1), size(y,2));

Ai2 = sum(A.^2);

% initialize r = y-Ax
for iter=1:nb_iter
  % additional calibration
  r = y - A*x;
  
  for i=1:size(x, 1)
    % x_new = Ai'( y - A_i x_i )/Ai'Ai = Ai'( y - Ax + Aixi) / Ai'Ai = 
    %       = Ai'r + Ai'(A_ix_i) + xi
    xi_add = A(:,i)'*r / Ai2(i);
    
    % r = y - A x = r_old - A x_add = r_old - Ai xi_add
    r = r - A(:,i) * xi_add;
    
    x(i,:) = x(i,:) + xi_add;
  end

%   disp(rms(r(:)));
end

val = rms(r(:));

