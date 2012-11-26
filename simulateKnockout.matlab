function winner = simulateKnockout(model,teams)

    nrounds = log2(length(teams));
    
    if fix(nrounds) ~= nrounds
        error('Number of teams must be a power of 2')
    end
    
    for n = 1:nrounds
        teams = simulateRound(model,teams);
    end
    
    winner = teams{1};

end

function result = simulateRound(model,teams)
    ngames = length(teams) / 2;
    result = cell(ngames);
    
    for n = 1:ngames
       
        home = teams{2*n-1};
        away = teams{2*n};
        
        opts.homeadv = false;
        
        [home_score away_score] = simulateGame(model,home,away,opts);
        
        if home_score > away_score
            result{n} = home;
        elseif home_score < away_score
            result{n} = away;
        elseif home_score == away_score
            % 1. Extra time (20 minutes)
            opts.length = 0.25; 
            [home_score_et away_score_et] = simulateGame(model,home,away,opts);
            if home_score_et > away_score_et
                result{n} = home;
            elseif home_score_et < away_score_et
                result{n} = away;
            elseif home_score_et == away_score_et
                % 2. Sudden death (10 minutes)
                first_to_score = simulateSuddenDeath(model,home,away);
                if ~isempty(first_to_score)
                    result{n} = first_to_score;
                else
                    % 3. Kicking competition
                    result{n} = simulateKickingCompetition(model,home,away);
                end
            end
        end
        
    end

end

function first_to_score = simulateSuddenDeath(model,home,away)
    opts.homeadv = false;
    opts.length = 0.125;
    
    [lambda_t_h lambda_p_h junk lambda_t_a lambda_p_a] = getRateParameters(model,home,away,opts);
    
    % Times of first try/penalty (the function exprnd generates
    % exponentially distributed random variables, and takes the mean
    % (rather than the rate) as its first parameter.
    htry = exprnd(1/lambda_t_h);
    hpen = exprnd(1/lambda_p_h);
    atry = exprnd(1/lambda_t_a);
    apen = exprnd(1/lambda_p_a);
    
    if any([htry hpen atry apen] < 1)
        [tmp idx] = min([htry hpen atry apen]);
        if idx == 1 || idx == 2
            first_to_score = home;
        else
            first_to_score = away;
        end
    else
        first_to_score = '';
    end
        
end

function winner = simulateKickingCompetition(model,home,away)
    [junk junk conv_h junk junk conv_a] = getRateParameters(model,home,away);
    
    % First take 5 kicks each
    home_kicks = binornd(5,conv_h);
    away_kicks = binornd(5,conv_a);
    
    if home_kicks > away_kicks
        winner = home;
    elseif home_kicks < away_kicks
        winner = away;
    elseif home_kicks == away_kicks
        % First team to succeed when the other fails is the winner
        done = false;
        while ~done
            home_kick = binornd(1,conv_h);
            away_kick = binornd(1,conv_a);
            if home_kick && ~away_kick
                winner = home;
                done = true;
            elseif away_kick && ~home_kick
                winner = away;
                done = true;
            else
                % Continue kicking...
            end
        end
    end
    
end