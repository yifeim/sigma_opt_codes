function [h] = plot_accu(accu_matrix, specs, errbar, opts)

mean_accu = mean(accu_matrix')';
se_accu   =   se(accu_matrix')';

default opts = struct();

h = plot_accu_mn_se(mean_accu, se_accu, specs, errbar, opts);
