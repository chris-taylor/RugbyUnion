function bets = getBets(model,fixtures)

    for n = 1:length(fixtures)
        bets(n) = getBet(model,fixtures(n)); %#ok
    end
    
end

function bet = getBet(model,fixture)
    
    % Discount factor - this is the cost paid to BetFair on any profits.
    
    df = 0.95;

    % Get model probabilities and create a struct of possible bets on this
    % market.
    
    prob = predict(model, fixture.home.team, fixture.away.team);
    bets = findAllBets(fixture,prob,df);
    
    % Pull out the bet with the highest information ratio.
    
    [junk idx] = max([bets.ir]);
    
    bet = bets(idx);

end

function out = findAllBets(fixture,probs,discountFactor)
    [bet(1) bet(2)] = backAndLay(fixture.home,probs(1));
    [bet(3) bet(4)] = backAndLay(fixture.away,probs(3));
    
    for n = 1:4
        out(n) = getEV(bet(n),discountFactor); %#ok
    end
end

function [back lay] = backAndLay(data,p)

    marketprob = 1 / ((data.odds(1) + data.odds(2)) / 2);

    % Back
    back.dir  = 'Back';
    back.team = data.team;
    back.win  = data.odds(1) - 1;
    back.lose = -1;
    back.prob = p;
    back.odds = data.odds(1);
    back.marketprob = marketprob;
    
    % Lay
    lay.dir  = 'Lay';
    lay.team = data.team;
    lay.win  = 1;
    lay.lose = 1 - data.odds(2);
    lay.prob = 1-p;
    lay.odds = data.odds(2);
    lay.marketprob = 1 - marketprob;
    
end

function bet = getEV(bet,discountFactor)

    % Probabilities
    p = bet.prob;
    q = bet.marketprob;
    
    % Bet characteristics
    bet.expectation       = p * discountFactor * bet.win + (1-p) * bet.lose;
    bet.marketexpectation = q * discountFactor * bet.win + (1-q) * bet.lose;
    bet.stdev             = sqrt(p * (1-p) * (discountFactor * bet.win - bet.lose)^2);
    bet.marketstdev       = sqrt(q * (1-q) * (discountFactor * bet.win - bet.lose)^2);
    bet.ir                = bet.expectation / bet.stdev;
    bet.marketir          = bet.expectation / bet.marketstdev;
end