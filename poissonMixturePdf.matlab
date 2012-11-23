function prob = poissonMixturePdf(scores,lambda,mu,p)
%Poisson/binomial mixture model.
%   scores  Scorelines you want a probability for
%   lambda  Rate of try scoring
%   mu      Rate of penalty/drop goal scoring
%   p       Probability of conversion

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