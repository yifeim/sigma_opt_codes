function [yfit] = graph_prediction_fcn(trainset, ytrain, testset, A, opts)

default opts = struct();
num_iterations = get_option(opts, 'num_iterations', 20);

switch class(ytrain)
  case 'nominal'
    cat_train = nom2catlab(ytrain')';
    
    yfit = label_propagation(A, cat_train, trainset, testset, num_iterations);

    yfit = cat2nomlab(yfit')';
  otherwise
    
    yfit = label_propagation(A, ytrain, trainset, testset, num_iterations);

end

end
