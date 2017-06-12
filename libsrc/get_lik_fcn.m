function [sigmoid, loglik, dloglik, ddloglik] = get_lik_fcn(lik)

switch(lik{1})
  case 'likLogistic'
    logistic = @(z) 1./(1+exp(-z));
    sigmoid  = logistic;
    loglik     = @(y,f) sum(log(logistic( y.*f )));
    dloglik    = @(y,f) y.*(1-logistic( y.*f ));
    ddloglik   = @(y,f) - logistic(f) .* (1-logistic(f)); % -W
    
  %   case {'likErf','likProbit'}
  case 'likErf';
    N   = @normpdf;
    Phi = @normcdf;
    sigmoid = Phi;
    loglik     = @(y,f) sum(log(Phi( y.*f )));
    dloglik    = @(y,f) y.*N(f)./Phi(y.*f);
    ddloglik   = @(y,f) - N(f).^2./Phi(y.*f).^2 - y.*f.*N(f)./Phi(y.*f); % -W
  
  otherwise
    warning('lik not implemented');
    sigmoid = nan; loglik = nan; dloglik = nan; ddloglik = nan;
    return;
end
