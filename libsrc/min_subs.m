function [subi, subj, minA] = min_subs(A)
  [minA, idx] = min(A(:));
  [subi, subj] = ind2sub(size(A), idx);
end
