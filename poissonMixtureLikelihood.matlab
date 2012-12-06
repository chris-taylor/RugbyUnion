function ll = poissonMixtureLikelihood(model,data)
    
    [th ph ch ta pa ca] = getPoissonRegressionParameters(model,data.ihome,data.iaway,data.homeadv);
    
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