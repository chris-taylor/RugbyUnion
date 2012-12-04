function [result score_home score_away htries atries] = simulateGame(model,home,away,opts,n)

    % Default arguments
    if nargin < 5
        n = 1;
    end
    if nargin < 4
        opts = struct;
    end
    if ~isfield(opts,'homeadv')
        opts.homeadv = true;
    end
    if ~isfield(opts,'length')
        opts.length = 1;
    end
    if ~isfield(opts,'verbose')
        opts.verbose = false;
    end
    if ~isfield(opts,'extratime')
        opts.extratime = false;
    end
    if ~isfield(opts,'suddendeath')
        opts.suddendeath = false;
    end
    if ~isfield(opts,'kickingcompetition')
        opts.kickingcompetition = false;
    end
    
    % Simulate the game
    [lambda_t_h lambda_p_h conv_h lambda_t_a lambda_p_a conv_a] = getRateParameters(model,home,away,opts);

    htries = poissrnd(lambda_t_h,n,1);
    hpens  = poissrnd(lambda_p_h,n,1);
    hcons  = binornd(htries,conv_h);
    
    atries = poissrnd(lambda_t_a,n,1);
    apens  = poissrnd(lambda_p_a,n,1);
    acons  = binornd(atries,conv_a);
    
    score_home = 5 * htries + 3 * hpens + 2 * hcons;
    score_away = 5 * atries + 3 * apens + 2 * acons;
    
    if n == 1
        
        if score_home > score_away
            result = 'home win';
        elseif score_home < score_away
            result = 'away win';
        elseif score_home == score_away
            result = 'draw';
        end
        
        if strcmp(result,'draw') && opts.extratime
            opts_extratime = opts;
            opts_extratime.length = 0.25;
            opts_extratime.extratime = false;
            result = simulateGame(model,home,away,opts_extratime,1);
        end
        
        if strcmp(result,'draw') && opts.extratime && opts.suddendeath
            result = simulateSuddenDeath(model,home,away,opts);
        end
        
        if strcmp(result,'draw') && opts.extratime && opts.suddendeath && opts.kickingcompetition
            result = simulateKickingCompetition(model,home,away);
        end
        
    else
        homewin = score_home > score_away;
        awaywin = score_home < score_away;
        draw    = score_home == score_away;
        result = cell(n,1);
        result(homewin) = {'home win'};
        result(awaywin) = {'away win'};
        result(draw)    = {'draw'};
    end
    
%     % Stats/output
%     if opts.verbose
%         prob_home_win = mean(score_home > score_away);
%         prob_away_win = mean(score_home < score_away);
%         prob_draw     = mean(score_home == score_away);
% 
%         prob_home_loses_by_less_than_7 = mean(score_home < score_away & (score_away - score_home <= 7));
%         prob_away_loses_by_less_than_7 = mean(score_away < score_home & (score_home - score_away <= 7));
% 
%         prob_home_scores_at_least_4_tries = mean(htries >= 4);
%         prob_away_scores_at_least_4_tries = mean(atries >= 4);
%     
%         fprintf('P(%s win) = %.1f%%\n',home,100*prob_home_win)
%         fprintf('P(%s win) = %.1f%%\n',away,100*prob_away_win)
%         fprintf('P(draw) = %.1f%%\n',100*prob_draw)
%         fprintf('P(%s within 7) = %.1f%%\n',home,100*prob_home_loses_by_less_than_7);
%         fprintf('P(%s within 7) = %.1f%%\n',away,100*prob_away_loses_by_less_than_7);
%         fprintf('P(%s >= 4 tries) = %.1f%%\n',home,100*prob_home_scores_at_least_4_tries);
%         fprintf('P(%s >= 4 tries) = %.1f%%\n',away,100*prob_away_scores_at_least_4_tries);
%         fprintf('Median total score: %d\n',median(score_home+score_away));
%     end
    
end

function result = simulateSuddenDeath(model,home,away,opts)
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
            result = 'home win';
        else
            result = 'away win';
        end
    else
        result = 'draw';
    end
    
end

function result = simulateKickingCompetition(model,home,away)
    [junk junk conv_h junk junk conv_a] = getRateParameters(model,home,away);
    
    % First take 5 kicks each
    home_kicks = binornd(5,conv_h);
    away_kicks = binornd(5,conv_a);
    
    if home_kicks > away_kicks
        result = 'home win';
    elseif home_kicks < away_kicks
        result = 'away win';
    elseif home_kicks == away_kicks
        % First team to succeed when the other fails is the winner
        done = false;
        while ~done
            home_kick = binornd(1,conv_h);
            away_kick = binornd(1,conv_a);
            if home_kick && ~away_kick
                result = 'home win';
                done = true;
            elseif away_kick && ~home_kick
                result = 'away win';
                done = true;
            else
                % Continue kicking...
            end
        end
    end
    
end