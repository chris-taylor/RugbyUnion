function [score_home score_away htries atries] = simulateGame(model,home,away,opts,n)

    % Default arguments
    if nargin < 5
        n = 1;
    end
    if nargin < 4
        opts = struct;
    end
    if ~isfield(opts,'homeadv')
        keyboard
        opts.homeadv = true;
    end
    if ~isfield(opts,'length')
        opts.length = 1;
    end
    if ~isfield(opts,'verbose')
        opts.verbose = false;
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
    
    % Stats/output
    if opts.verbose
        prob_home_win = mean(score_home > score_away);
        prob_away_win = mean(score_home < score_away);
        prob_draw     = mean(score_home == score_away);

        prob_home_loses_by_less_than_7 = mean(score_home < score_away & (score_away - score_home <= 7));
        prob_away_loses_by_less_than_7 = mean(score_away < score_home & (score_home - score_away <= 7));

        prob_home_scores_at_least_4_tries = mean(htries >= 4);
        prob_away_scores_at_least_4_tries = mean(atries >= 4);
    
        fprintf('P(%s win) = %.1f%%\n',home,100*prob_home_win)
        fprintf('P(%s win) = %.1f%%\n',away,100*prob_away_win)
        fprintf('P(draw) = %.1f%%\n',100*prob_draw)
        fprintf('P(%s within 7) = %.1f%%\n',home,100*prob_home_loses_by_less_than_7);
        fprintf('P(%s within 7) = %.1f%%\n',away,100*prob_away_loses_by_less_than_7);
        fprintf('P(%s >= 4 tries) = %.1f%%\n',home,100*prob_home_scores_at_least_4_tries);
        fprintf('P(%s >= 4 tries) = %.1f%%\n',away,100*prob_away_scores_at_least_4_tries);
        fprintf('Median total score: %d\n',median(score_home+score_away));
    end
    
end