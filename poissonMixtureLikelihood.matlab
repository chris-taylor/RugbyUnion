function ll = poissonMixtureLikelihood(model,data,homeadv)

    if nargin < 3
        homeadv = true;
    end

    XH = data.X; XH(XH<0)=0;
    XA = -data.X; XA(XA<0)=0;
    opts.homeadv = homeadv;
    iHome = sum(cumsum(fliplr(XH),2),2); % takes the selection matrix and converts to team indexes
    iAway = sum(cumsum(fliplr(XA),2),2); % (as above)
    
%     [th ph ch ta pa ca] = getRateParameters(model,iHome,iAway,opts);
    [th ph ch ta pa ca] = getPoissonRegressionParameters(model,iHome,iAway,opts);
    
    triesll = poissonll(th,ta,data.hometries,data.awaytries);
    pensll  = poissonll(ph,pa,data.homepens+data.homedrops,data.awaypens+data.awaydrops);
    consll  = binoll(ch,data.hometries,data.homecons) + binoll(ca,data.awaytries,data.awaycons);
    
    ll = mean(triesll + pensll + consll);
    
end

function ll = poissonll(lambda,mu,x,y)
    ll = - lambda - mu + x .* log(lambda) + y .* log(mu) - logfact(x) - logfact(y);
end

function ll = binoll(p,tries,cons)
    ll = cons .* log(p) + (tries - cons) .* log(1-p) + lognchoosek(tries,cons);
end

function y = logfact(x)
    y = gammaln(x+1);
end

function y = lognchoosek(n,k)
    y = gammaln(n+1) - gammaln(k+1) - gammaln(n-k+1);
end