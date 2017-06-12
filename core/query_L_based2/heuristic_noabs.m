function [query, greedyObj, objs2min] = heuristic_noabs(...
  K, ell, y_ell, opts)

if nargin<4, opts=struct(); end
nb_samples = get_option(opts,'nb_samples',200);

useSampling = ~isfield(opts, 'myBVN');
myBVN_fcn = get_option(opts, 'myBVN', @myBVN);

useMVN = get_option(opts, 'useMVN', false);
myMVN_fcn = get_option(opts, 'myMVN', @myMVN);

useparfor = get_option(opts, 'useparfor', false); % useBVN

useparBVN = get_option(opts, 'useparBVN', false);

%% model
lik = get_option(opts, 'lik' , {'likErf'});
if ~strcmpi(lik,'likErf'), warning('active assumes likErf'); end
sigmoid = get_lik_fcn(lik);

covs = {@covConstMatrix, K};  
mn  = {'meanZero'};      

hyp = struct('cov',[],'lik',[],'mean',[]);

%% init
pool = comple(ell, length(K))';
% first compute p(y_u|y_ell)
if isempty(ell)
  meanyp_1 = .5*ones(size(pool));
else
  [post] = infEP(hyp, mn, covs, lik, ell, y_ell);
  % [~, ha, ~, ~, K_cova] = kernelized_sigmoid_regression([], K(ell, ell), y_ell);
  
  Si = inv( K(ell,ell) + diag(post.sW .^ -2) );
  
  meanfp = K(pool, ell)*post.alpha;
  covfp = K(pool, pool) - K(pool, ell)*Si*K(ell,pool);
  
  meanyp_1 = sigmoid( meanfp ./ sqrt(1+diag(covfp)) );
end

% variance = inf(2, length(pool));
objs2min = inf(1, length(pool));

tic;

if ~useparfor
  
  for i=1:length(pool)    
    ell_c = [pool(i); ell];
    pool_c = pool([1:i-1, i+1:end]);
    tril_ind = tril(true(length(pool_c)), -1);
    
    yc = [1, -1];
    
    variance = inf(2);
    for yc_i = 1:2
      %     [~, ha_c, ~, ~, K_cova_c] = kernelized_sigmoid_regression( ...
      %       [], K(ell_c, ell_c), [yc(yc_i); y_ell]);
      
      
      %% toolbox EP
      [post_c] = infEP(hyp, mn, covs, lik, ell_c, [yc(yc_i); y_ell]);
      Si_c = inv( K(ell_c,ell_c) + diag(post_c.sW .^ -2) );
      
      meanfp_c = K(pool_c, ell_c)*post_c.alpha;
      covfp_c = K(pool_c, pool_c) - K(pool_c, ell_c)*Si_c*K(ell_c, pool_c);
      
      diag_covfp_c = diag(covfp_c);
      
      % marginals are analytical
      ey  = sigmoid( meanfp_c./sqrt(1+diag_covfp_c));
      varyp_c = 4 * ey .* (1-ey);
      
      
      if useSampling
        
        % draw sample
        sfp_c   = mvnrnd(meanfp_c', covfp_c, nb_samples)';
        %     covyp_c = 4 * sigmoid(sfp_c')'*sigmoid(sfp_c')/nb_samples ...
        %       - 4 * mean(sigmoid(sfp_c'))' * mean(sigmoid(sfp_c'));
        %
        %     covyp_c2 = ey2 - ey*ey';
        
        covyp_c = 4 * cov(sigmoid(sfp_c)', 1);
        cov_varyp_c = diag(varyp_c - diag(covyp_c)) + covyp_c;
        
        
      else %useBVN or useMVN
        
        BvN_mu = meanfp_c ./ sqrt(1+diag_covfp_c);
        BvN_sigma = sqrt(1+diag_covfp_c);
        

        if useMVN
          
          cov_varyp_c = myMVN_fcn(BvN_mu, covfp_c, ey, BvN_sigma);
          cov_varyp_c = cov_varyp_c + cov_varyp_c' - diag(diag(cov_varyp_c));
          
%           %debug
%           
%           BvN_rhos = bsxfun(@rdivide,covfp_c,BvN_sigma);
%           BvN_rhos = bsxfun(@rdivide,BvN_rhos,BvN_sigma');
%           rhos = BvN_rhos(tril_ind);
%           
%           [BvN_mu1, BvN_mu2] = meshgrid(BvN_mu, BvN_mu);
%           Xs = [BvN_mu1(tril_ind), BvN_mu2(tril_ind)];
%           
%           if useparBVN
%             slices = round(linspace(0, length(rhos), matlabpool('size')+1));
%             ey2v = {};
%             parfor slice_id = 1:length(slices)-1;
%               this_slice = slices(slice_id)+1:slices(slice_id+1);
%               ey2v{slice_id} = myBVN_fcn(Xs(this_slice, :), rhos(this_slice, :));
%             end
%             ey2v = cell2mat(ey2v');
%           else
%             ey2v = myBVN_fcn(Xs, rhos);
%           end
%           
%         
%           ey2 = squareform(ey2v);
%           covyp_c = 4 * ey2 - 4 * ey*ey';
%           cov_varyp_c0 = diag(varyp_c - diag(covyp_c)) + covyp_c;
%           
%           %debug
%           assert(mateq(cov_varyp_c0, cov_varyp_c));
          
        else
          
          BvN_rhos = bsxfun(@rdivide,covfp_c,BvN_sigma);
          BvN_rhos = bsxfun(@rdivide,BvN_rhos,BvN_sigma');
          rhos = BvN_rhos(tril_ind);
          
          [BvN_mu1, BvN_mu2] = meshgrid(BvN_mu, BvN_mu);
          Xs = [BvN_mu1(tril_ind), BvN_mu2(tril_ind)];
          
          ey2 = squareform(myBVN_fcn(Xs, rhos));
          covyp_c = 4 * ey2 - 4 * ey*ey';
          cov_varyp_c = diag(varyp_c - diag(covyp_c)) + covyp_c;
        
        end

      end
      %
      %     imagesc(cov_varyp_c- cov_varyp_c0);
      %     colorbar;
      %     pause(.1);
      
      variance(yc_i) = sum(sum((cov_varyp_c)));
    end
    objs2min(i) = variance(1) * meanyp_1(i) + variance(2) * (1-meanyp_1(i));
    if isodd(i, 10), disp([length(ell_c), i]);   toc; disp(clock);  end
  end
  
else % useparfor
  
  parfor i=1:length(pool)
    ell_c = [pool(i); ell];
    pool_c = pool([1:i-1, i+1:end]);
    tril_ind = tril(true(length(pool_c)), -1);
    
    yc = [1, -1];
    
    variance = inf(2);
    for yc_i = 1:2
      %     [~, ha_c, ~, ~, K_cova_c] = kernelized_sigmoid_regression( ...
      %       [], K(ell_c, ell_c), [yc(yc_i); y_ell]);
      
      
      %% toolbox EP
      [post_c] = infEP(hyp, mn, covs, lik, ell_c, [yc(yc_i); y_ell]);
      Si_c = inv( K(ell_c,ell_c) + diag(post_c.sW .^ -2) );
      
      meanfp_c = K(pool_c, ell_c)*post_c.alpha;
      covfp_c = K(pool_c, pool_c) - K(pool_c, ell_c)*Si_c*K(ell_c, pool_c);
      
      diag_covfp_c = diag(covfp_c);
      
      % marginals are analytical
      ey  = sigmoid( meanfp_c./sqrt(1+diag_covfp_c));
      varyp_c = 4 * ey .* (1-ey);
      
      % bvn to compute the cov
      BvN_mu = meanfp_c ./ sqrt(1+diag_covfp_c);
      BvN_sigma = sqrt(1+diag_covfp_c);
      
      if useMVN
        
          cov_varyp_c = myMVN_fcn(BvN_mu, covfp_c, ey, BvN_sigma);
          cov_varyp_c = cov_varyp_c + cov_varyp_c' - diag(diag(cov_varyp_c));
        
      else %useBVN
        
        BvN_rhos = bsxfun(@rdivide,covfp_c,BvN_sigma);
        BvN_rhos = bsxfun(@rdivide,BvN_rhos,BvN_sigma');
        
        [BvN_mu1, BvN_mu2] = meshgrid(BvN_mu, BvN_mu);
        Xs = [BvN_mu1(tril_ind), BvN_mu2(tril_ind)];
        rhos = BvN_rhos(tril_ind);
        
        ey2 = squareform(myBVN_fcn(Xs, rhos));
        covyp_c = 4 * ey2 - 4 * ey*ey';
        
        % summarize
        cov_varyp_c = diag(varyp_c - diag(covyp_c)) + covyp_c;
        %
        %     imagesc(cov_varyp_c- cov_varyp_c0);
        %     colorbar;
        %     pause(.1);
      end
      
      variance(yc_i) = sum(sum((cov_varyp_c)));
    end
    objs2min(i) = variance(1) * meanyp_1(i) + variance(2) * (1-meanyp_1(i));
    if isodd(i, 10), clk = clock; disp([length(ell_c), i, clk(4:6)]);  end
  end
  
end

toc;

[~, c_i] = min(objs2min);
query = pool(c_i);
greedyObj = objs2min(c_i);

