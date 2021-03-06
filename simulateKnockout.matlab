function result = simulateKnockout(model,teams,host)

    nrounds = log2(length(teams));
    
    if fix(nrounds) ~= nrounds
        error('Number of teams must be a power of 2')
    end
    
    teams_ = teams;
    for n = 1:nrounds-2
        teams_ = simulateRound(model,teams_,host);
    end
    
    [semiFinalWinners semiFinalLosers] = simulateRound(model,teams_,host);
    
    [first second] = simulateRound(model,semiFinalWinners,host);
    [third fourth] = simulateRound(model,semiFinalLosers,host);

    result.winner = first;
    result.second = second;
    result.third  = third;
    result.fourth = fourth;
    result.quarterFinalists = teams;
    result.semiFinalists = teams_;
    result.finalists = semiFinalWinners;
    result.playoffs = semiFinalLosers;
    
end

function [winners losers] = simulateRound(model,teams,host)
    ngames = length(teams) / 2;
    winners = zeros(ngames,1);
    losers = zeros(ngames,1);
    
    for n = 1:ngames
       
        home = teams(2*n-1);
        away = teams(2*n);
        
        if home == host
            opts.homeadv = 1;
        elseif away == host
            opts.homeadv = -1;
        else
            opts.homeadv = 0;
        end
        
        opts.extratime          = true;
        opts.suddendeath        = true;
        opts.kickingcompetition = true;
        
        gameResult = simulateGame(model,home,away,opts);
        
        switch gameResult
            case 'home win'
                winners(n) = home;
                losers(n) = away;
            case 'away win'
                winners(n) = away;
                losers(n) = home;
            otherwise
                disp('Eep?')
                keyboard
        end
        
    end

end