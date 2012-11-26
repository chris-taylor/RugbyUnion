function payoff = getPayoffs(bets,results,df)

    payoff = zeros(length(bets),1);

    for n = 1:length(bets)
        payoff(n) = getPayoff(bets(n),results{n},df);
    end

end

function payoff = getPayoff(bet,result,df)

    switch bet.dir
        case 'Back'
            if strcmp(bet.team,result)
                payoff = df * bet.capital * bet.win;
            else
                payoff = bet.capital * bet.lose;
            end
        case 'Lay'
            if strcmp(bet.team,result)
                payoff = bet.capital * bet.lose;
            else
                payoff = df * bet.capital * bet.win;
            end
    end
    
end