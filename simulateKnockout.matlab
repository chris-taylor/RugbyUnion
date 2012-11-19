function winner = simulateKnockout(teams,predfun)

    nrounds = log2(length(teams));
    
    if fix(nrounds) ~= nrounds
        error('Number of teams must be a power of 2')
    end
    
    for n = 1:nrounds
        teams = simulateround(teams,predfun);
    end
    
    winner = teams{1};

end

function result = simulateround(teams,predfun)

    ngames = length(teams) / 2;
    result = cell(ngames);
    
    for n = 1:ngames
       
        home = teams{2*n-1};
        away = teams{2*n};
        
        prob = predfun(home,away);
        prob = prob(1) / sum(prob(1:2));
        
        if rand() < prob
            result{n} = home;
        else
            result{n} = away;
        end
        
    end

end