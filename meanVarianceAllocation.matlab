function bet = meanVarianceAllocation(bet,capital,lambda)
   
    % Set negative expectation bets to zero
    
    positive = [bet.expectation] > 0;
    
    alpha = [bet(positive).expectation];
    sigma = [bet(positive).marketstdev].^2;

    nu = ( sum(alpha./sigma) - lambda ) / sum(1./sigma);
    
    % Allocate capital
    
    w = zeros(length(bet),1);
    w(positive) = capital * (alpha - nu) ./ (lambda * sigma);
    
    % Assign to bets
    
    for n = 1:length(bet)
        bet(n).capital = w(n);
    end
    
end