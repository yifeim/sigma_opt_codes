function [query, greedyObj, objs2min] = heuristic_trace_active_new(...
  K, ell, y_ell, opts)

if nargin<4, opts=struct(); end

%% model
lik = get_option(opts, 'lik' , {'likErf'});
if ~strcmpi(lik,'likErf'), warning('active assumes likErf'); end
sigmoid = get_lik_fcn(lik);

covs = {@covConstMatrix, K};  
mn  = {'meanZero'};      

hyp = struct('cov',[],'lik',[],'mean',[]);

%% init
ws = struct('ttau', {[]}, 'tnu', {[]});
pool = comple(ell, length(K))';
% first compute p(y_u|y_ell)
if isempty(ell)
  meanyp_1 = .5*ones(size(pool));
else
%   [post, ws] = infEP_warm(hyp, ws, mn, covs, lik, ell, y_ell);
   [post] = infEP(hyp, mn, covs, lik, ell, y_ell);

  % [~, ha, ~, ~, K_cova] = kernelized_sigmoid_regression([], K(ell, ell), y_ell);
  
  Si = inv( K(ell,ell) + diag(post.sW .^ -2) );
  
  meanfp = K(pool, ell)*post.alpha;
  covfp = K(pool, pool) - K(pool, ell)*Si*K(ell,pool);
  
  meanyp_1 = sigmoid( meanfp ./ sqrt(1+diag(covfp)) );
end

variance = inf(2, length(pool));
objs2min = inf(1, length(pool));

augws = struct('ttau', {[0; ws.ttau]}, 'tnu', {[0; ws.tnu]});

for i=1:length(pool)
  ell_c = [pool(i); ell];
  pool_c = pool([1:i-1, i+1:end]);
  
  yc = [1, -1];
  for yc_i = 1:2
    %     [~, ha_c, ~, ~, K_cova_c] = kernelized_sigmoid_regression( ...
    %       [], K(ell_c, ell_c), [yc(yc_i); y_ell]);
    
    
    %% toolbox EP
    [post_c] = infEP(hyp, mn, covs, lik, ell_c, [yc(yc_i); y_ell]);
%     [post_c_ws] = infEP_warm(hyp, augws, mn, covs, lik, ell_c, [yc(yc_i); y_ell]);
%     assert(mateq(post_c.sW, post_c_ws.sW, 1e-2));
   
    Si_c = inv( K(ell_c,ell_c) + diag(post_c.sW .^ -2) );

    %toolbox
%     [~, ys2_c] = gp(hyp, @infEP, mn, covs, lik, ell_c, post_c, pool_c);
%     variance(yc_i, i) = sum(abs(ys2_c));

    % myimp
    meanfp_c = K(pool_c, ell_c)*post_c.alpha;
    diag_covfp_c = feval(covs{:}, hyp.cov, pool_c, 'diag') - ...
      sum(K(ell_c, pool_c) .* (Si_c * K(ell_c, pool_c)), 1)';
%     covfp_c = K(pool_c, pool_c) - K(pool_c, ell_c)*Si_c*K(ell_c, pool_c);

    % marginals are analytical
    ey  = sigmoid( meanfp_c./sqrt(1+diag_covfp_c));
    varyp_c = 4 * ey .* (1-ey);
           
    variance(yc_i, i) = sum(abs(varyp_c));
%     assert(mateq( variance(yc_i, i) ,  sum(abs(varyp_c)),  1e-2 ));
  end
  objs2min(i) = variance(1, i) * meanyp_1(i) + variance(2,i) * (1-meanyp_1(i));
end

[~, c_i] = min(objs2min);
query = pool(c_i);
greedyObj = objs2min(c_i);

