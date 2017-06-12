function [hf, ha, tm, ts2, K_cova, logpost] = ...
  kernelized_sigmoid_regression(lik, K, y)
% x not required as input but needs to match K & y because of the output


% about the sigmoid model
if iscell(lik), lik=lik{1}; end
if isempty(lik), lik = 'likProbit'; end

[sigmoid, loglik, dloglik, ddloglik] = get_lik_fcn(lik);

if isnan(sigmoid)
  hf = zeros(size(y)); ha=hf; tm=hf; ts2=hf; logpost=@(z) 0;
  return;
end

% switch(lik)
%   case 'likLogistic'
%     logistic = @(z) 1./(1+exp(-z));
%     loglik     = @(f) sum(log(logistic( y.*f )));
%     dloglik    = @(f) y.*(1-logistic( y.*f ));
%     ddloglik   = @(f) - logistic(f) .* (1-logistic(f)); % -W
%     
%   case {'likErf','likProbit'}
%     N   = @normpdf;
%     Phi = @normcdf;
%     loglik     = @(f) sum(log(Phi( y.*f )));
%     dloglik    = @(f) y.*N(f)./Phi(y.*f);
%     ddloglik   = @(f) - N(f).^2./Phi(y.*f).^2 - y.*f.*N(f)./Phi(y.*f); % -W
%   
%   otherwise
%     warning('lik not implemented');
%     hf = zeros(size(y)); ha=hf; tm=hf; ts2=hf; logpost=@(z) 0;
%     return;
% end

% information matrix I_post = invK + I_lik, W
info_lik   = @(f) - ddloglik(y,f);  

% about kernel a ~ N(0, K^{-1}) <=> f ~ N(0, K)
logprior   = @(a) - .5*a'*K*a ;

% posteriors
logpost    = @(a) loglik(y,K*a) + logprior(a);
dlogpost   = @(a) K*dloglik(y,K*a) - K*a;

% S = (K^-1 + tS^-1)^-1 = (K^-1 + W)^-1 
postcov   = @(f) K - K * inv( K + diag(info_lik(f).^-1) ) * K;
Kipostcov = @(f) eye(length(K)) - ( K + diag(info_lik(f).^-1) ) \ K;

% maximize (unnormalized) logpost
ha = zeros(size(y));
hf = K*ha;

for iter = 1:10
  
  gradha = dlogpost(ha);
  % eq 3.18 & ha_new = K\hf_new
  hadir  = Kipostcov(hf) * (info_lik(hf).*hf + dloglik(y,hf)) - ha;
  
  % uphill linesearch. because the obj is concave (log-concavity of the 
  % logistic sigmoid), no need to check the gradient at (ha + t*hadir).
  for t=10.^(0:-1:-14)
    if logpost(ha + t*hadir) - logpost(ha) > 1e-4*t*hadir'*gradha
      break;
    end
  end
  
  ha = ha + t*hadir;
  hf = K*ha;
  
  fprintf(...
    'kernelized sigmoid regression. iter=%d, stepsize=10^%d, logpost=%f\n', ...
    [iter, log10(t), logpost(ha)]);
  
end


% local Gaussian likelihood fits
ts2 = info_lik(hf).^-1;  % ts2 = W^-1
tm  = (K + diag(ts2))*ha; %hf = postcov ts2^-1 tm = K (K+ts2)^-1 tm

% K^-1 - K^-1 S K^-1 = inv( K + tS )
K_cova = inv( K + diag(ts2) );
