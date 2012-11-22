function [pts probs] = multiComponentModel(lambda,mu,p)
%Model for rugby scorelines based on:
%   Number of tries:           X ~ Poisson(lambda)
%   Number of penalties/drops: Y ~ Poisson(mu)
%   Number of conversions:     Z ~ Binomial(x,p)

    % monte carlo
    
%     n = 1e6;
%     
%     x = poissrnd(lambda,n,1);
%     y = poissrnd(mu,n,1);
%     z = binornd(x,p);
%     
%     s = 5 * x + 3 * y + 2 * z;
%     
%     c = count(s);
%     
%     mean_ = mean(s);
%     var_  = var(s);
%     std_  = std(s);
%     
%     pts = c.vals;
%     probs = c.freqs;
    
    % explicit
    
    pts   = (0 : 150)';
    probs = multiPoissonPdf(pts,lambda,mu,p);
    
    mean_   = sum(pts .* probs);
    median_ = stats.distMedian(pts,probs);
    var_    = sum((pts - mean_).^2 .* probs);
    std_    = sqrt(var_);
    
    % plot/output
    
    fprintf('Mean score:   %.2f\n',mean_)
    fprintf('Median score: %.2f\n',median_)
    fprintf('Std Dev:      %.2f\n',std_)
    fprintf('Variance:     %.2f\n',var_)
    
    bar(pts,probs)
    grid on
    
end

function prob = multiPoissonPdf(scores,lambda,mu,p)

    prob = zeros(size(scores));
    
    % pre-compute X, Y, Z probabilities
    
    xs = 0 : floor(max(scores)/5);
    px = stats.poissonpdf(xs,lambda);
    
    ys = 0 : floor(max(scores)/3);
    py = stats.poissonpdf(ys,mu);
    
    zs = 0 : floor(max(xs));
    pz = binopdf(repmat(xs,length(zs),1),repmat(zs',1,length(xs)),p);

    % loop over all combinations that sum to a given score
    
    for i = 1:length(scores)
        
        s = scores(i);
        
        if s < 0 || s == 1 || s == 2 || s == 4 || ~(fix(s) == s)
            continue
        end
        
        for x = 0 : floor(s/5)            % number of tries
            for y = 0 : floor((s-5*x)/3)  % number of penalty/drop goals
                z  = (s - 5*x - 3*y) / 2; % number of conversions
                if z < 0 || z > x || ~(fix(z) == z)
                    continue
                else
                    prob(i)  = prob(i) + px(x+1) * py(y+1) * pz(x+1,z+1);
                end
            end
            
        end
        
    end

end