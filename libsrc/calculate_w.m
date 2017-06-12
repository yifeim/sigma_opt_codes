num_nodes = size(L, 1);

% for example
K = inv(L(1:(end - 1), 1:(end - 1)));

train_ind = (1:10)';
test_ind  = setdiff(1:num_nodes, train_ind)';

mean_function       = {@meanZero};
covariance_function = {@covConstMatrix, K};
likelihood          = @likLogistic;

hyperparameters.mean = [];
hyperparameters.cov  = [];
hyperparameters.lik  = [];

posterior = infLaplace(hyperparameters, mean_function, covariance_function, ...
                       likelihood, train_ind, y(train_ind));

W = (posterior.sW).^2;