function payoffDistribution(bet)

    N = length(bet);
    p = [bet.marketprob];
    stake = [bet.capital];
    
    X = logical(binocombinations(N));

    prob = prod(bsxfun(@power,p,X) .* bsxfun(@power,1-p,1-X), 2);
    payoff = zeros(size(prob));
    
    win  = stake .* [bet.win];
    lose = stake .* [bet.lose];
    
    for i = 1:size(X,1)
        payoff(i) = sum(win(X(i,:))) + sum(lose(~X(i,:)));
    end
    
    getBins(payoff,prob,100);
    
end

function getBins(x,p,n)

    dx = range(x) / n;
    
    xs = min(x) : dx : max(x);
    ps = zeros(1, size(x,2)-1);
    
    for i = 1:n
       
        lo = xs(i);
        hi = xs(i+1);
        
        loc = x > lo & x <= hi;
        
        ps(i) = sum(p(loc));
        
    end
    
    bar(xs(1:end-1) + dx/2, ps), grid on

end