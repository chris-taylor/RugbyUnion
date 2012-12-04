function ll = poissonMixtureLikelihood(model,data,homeadv)

    if nargin < 3
        homeadv = true;
    end

    XH = data.X; XH(XH<0)=0;
    XA = -data.X; XA(XA<0)=0;
    
    triesll = poissonll(model.tries.c,model.tries.g,model.tries.a,model.tries.d,XH,XA,data.hometries,data.awaytries,homeadv);
    pensll  = poissonll(model.pens.c,model.pens.g,model.pens.a,model.pens.d,XH,XA,data.homepens+data.homedrops,data.awaypens+data.awaydrops,homeadv);
    consll  = binoll(model.cons.p,XH,data.hometries,data.homecons) + binoll(model.cons.p,XA,data.awaytries,data.awaycons);
    
    ll = mean(triesll + pensll + consll);
    
end

function ll = poissonll(c,g,a,d,XH,XA,x,y,homeadv)
    if homeadv
        lambda = c + XH * a - XA * d + g; % home team scoring rate
        mu     = c + XA * a - XH * d - g; % away team scoring rate
    else
        lambda = c + XH * a - XA * d;
        mu     = c + XA * a - XH * d;
    end
    ll = - lambda - mu + x .* log(lambda) + y .* log(mu) - logfact(x) - logfact(y);
end

function ll = binoll(teamp,X,tries,cons)
    p  = X * teamp;
    ll = cons .* log(p) + (tries - cons) .* log(1-p) + lognchoosek(tries,cons);
end

function y = logfact(x)
    y = gammaln(x+1);
end

function y = lognchoosek(n,k)
    y = gammaln(n+1) - gammaln(k+1) - gammaln(n-k+1);
end