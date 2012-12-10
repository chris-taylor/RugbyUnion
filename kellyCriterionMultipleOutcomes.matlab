function [f r]=kellyCriterionMultipleOutcomes(p,b,l,capital)

    p = p(:);
    b = b(:);
    l = l(:);
    
    if nargin < 4
        capital = 100;
    end
    
    n = length(p);
    
    m = 0.5 * (b + l); % mid market rate
    s = l - b;         % spread

    f0 = zeros(length(p),1);

    Acon = ones(1,length(p)); % A * f <= b
    bcon = 0.9999;
%     lb   = repmat(-0.2,length(p),1);
%     ub   = repmat(0.2,length(p),1);
    lb = -0.5 * 1./l;
    ub = 0.5 * ones(n,1);

    opts.Algorithm = 'active-set';
    opts.Display = 'off';
    
    [f fval] = fmincon(@(f)costFunction(p,m,s,f),f0,Acon,bcon,[],[],lb,ub,[],opts);
    
    r = -fval;
    v = variance(p,m,s,f);
     
    % Scale to capital
    f = round(f' * capital);
    
    %%%%%
     
%     rhalf = -costFunction(p,m,s,f/2);
%     vhalf = variance(p,m,s,f/2);

     
%     disp(' ')
%     disp('Kelly bets:')
%     disp(round(capital*f'))
% 
%     disp(' ')
%     fprintf('      Kelly rate: %.1f%%\n',100*r)
%     fprintf('     Kelly stdev: %.1f%%\n',100*sqrt(v))
%     fprintf('        Kelly ir: %.2f\n',r/sqrt(v))
%     
%     disp(' ')
%     disp('Half Kelly bets:')
%     disp(round(capital/2*f'))
% 
%   
%     disp(' ')
%     fprintf(' Half Kelly rate: %.1f%%\n',100*rhalf)
%     fprintf('Half Kelly stdev: %.1f%%\n',100*sqrt(vhalf))
%     fprintf('   Half Kelly ir: %.2f\n',rhalf/sqrt(vhalf))
% 
%     for ii = 1:101
%        
%         w = (ii-1)/100;
%         
%         r(ii) = -costFunction(p,m,s,w*f);
%         v(ii) = sqrt(variance(p,m,s,w*f));
%         
%     end
%     
%     plot(linspace(0,1,101), r,'b')
%     
%     hold on
%     
%     plot(linspace(0,1,101), v,'r')
%     
%     plot(linspace(0,1,101), r./v,'k')
%     
%     legend({'Rate of return','Volatility','Information ratio'})
%     
%     grid on
%     
%     xlabel({'Kelly fraction'})
    
end

function [cost grad] = costFunction(p,m,s,f)

    df = 0.95; %-- 5% commission
    
    winnings = f .* m - abs(f) .* s/2 - sum(f);
    winnings(winnings > 0) = df * winnings(winnings > 0);
    
    if any(winnings < -1)
        error('Negative wealth is possible with this combination of bets!')
    end
    
    rate = sum(p .* log(1 + winnings));
    
    cost = -rate;

end

function variance = variance(p,m,s,f)

    df = 0.95;
    
    winnings = f .* m - abs(f) .* s/2 - sum(f);
    winnings(winnings > 0) = df * winnings(winnings > 0);
    
    if any(winnings < -1)
        disp('Negative wealth is possible with this combination of bets!')
        keyboard
    end
    
    rate = sum(p .* log(1 + winnings));
    
    variance = sum(p .* (log(1+winnings) - rate).^2);
    
end

