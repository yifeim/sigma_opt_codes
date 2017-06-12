function [testlabels, P] = label_propagation(A, trainlabels, trainset, testset, opts)
% input: trainlabels N-by-C
% output: testlabels M-by-C

default opts = struct();
num_iterations = get_option(opts, 'num_iterations', round(20*(5254/length(A))^1.5));

num_total = numel(union(trainset, testset));

num_labels = size(trainlabels, 2);

if max(abs(1-sum(A,2))) <= 1e-8
  P = A;
else
  % normalize s.t. P*1=1, i.e. p^{t+1}=P*p^t
  P = diag(sum(A,2).^-1) * A; 
end

probabilities = zeros(num_total, num_labels);

for i = 1:num_iterations
  probabilities(trainset, :) = trainlabels;
  probabilities = P * probabilities;
end

testlabels = probabilities(testset, :);
