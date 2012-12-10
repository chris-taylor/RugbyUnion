function [f r] = kellyCriterion(p,b,s)

    f0 = zeros(length(p),1);

    Acon = ones(1,length(p)); % A * f <= b
    bcon = 0.9999;
    lb   = repmat(0,length(p),1);
    ub   = repmat(0.9999,length(p),1);

    [f fval] = fmincon(@(f)costFunction(p,b,f),f0,Acon,bcon,[],[],lb,ub);
    
    r = -fval;
    v = variance(p,b,f);
    
    rhalf = -costFunction(p,b,f/2);
    vhalf = variance(p,b,f/2);
    
%     fnaive = ((p .* b - (1-p) .* s) ./ (s.*b))';

    disp('Kelly fractions:')
    disp(f)
    
    fprintf('      Kelly rate: %.1f%%\n',100*r)
    fprintf('     Kelly stdev: %.1f%%\n',100*sqrt(v))
    fprintf('        Kelly ir: %.2f\n',r/sqrt(v))
    
    
    fprintf(' Half Kelly rate: %.1f%%\n',100*rhalf)
    fprintf('Half Kelly stdev: %.1f%%\n',100*sqrt(vhalf))
    fprintf('   Half Kelly ir: %.2f\n',rhalf/sqrt(vhalf))
    
    for ii = 1:101
       
        w = (ii-1)/100;
        
        r(ii) = -costFunction(p,b,w*f);
        v(ii) = sqrt(variance(p,b,w*f));
        
    end
    
    plot(linspace(0,1,101), r,'b')
    
    hold on
    
    plot(linspace(0,1,101), v,'r')
    
    plot(linspace(0,1,101), r./v,'k')
    
    legend({'Rate of return','Volatility','Information ratio'})
    
    grid on
    
    xlabel({'Kelly fraction'})
    
%     fprintf('     Naive rate: %.1f%%\n',-100*costFunction(p,b,fnaive))
    
end

function [cost grad] = costFunction(p,b,f)

    df = 0.95;
    n = length(p);
    x = binocombinations(n);

    ps = prod(bsxfun(@power,p,x) .* bsxfun(@power,1-p,1-x), 2);
    
    bs = bsxfun(@times,x,b) - (1-x);
    bs(bs>0) = df * bs(bs>0);
    
    wealth = 1 + sum(bsxfun(@times,bs,f'), 2);
    
    if any(wealth < 0)
        disp('Negative wealth possible with this combination of bets.')
        keyboard
    end
    
    cost = -sum(ps .* log(wealth), 1);

end

function variance = variance(p,b,f)

    n = length(p);
    x = binocombinations(n);

    ps = prod(bsxfun(@power,p,x) .* bsxfun(@power,1-p,1-x), 2);
    bs = bsxfun(@times,x,b) - (1-x);
    wealth = 1 + sum(bsxfun(@times,bs,f'), 2);
    
    meanLogWealth = sum(ps .* log(wealth), 1);
    variance = sum(ps .* (log(wealth) - meanLogWealth).^2, 1);

end