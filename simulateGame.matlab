function [score_home score_away htries atries] = simulateGame(model,home,away,homeadv,n)

    if nargin < 5
        n = 1;
    end
    
    if nargin < 4
        homeadv = true;
    end

    ihome = strmatch(home,model.teams,'exact');
    iaway = strmatch(away,model.teams,'exact');
    
    if homeadv
        lambda_t_h = model.tries.c + model.tries.g + model.tries.a(ihome) - model.tries.d(iaway);
        lambda_t_a = model.tries.c - model.tries.g + model.tries.a(iaway) - model.tries.d(ihome);
        lambda_p_h = model.pens.c + model.pens.g + model.pens.a(ihome) - model.pens.d(iaway);
        lambda_p_a = model.pens.c - model.pens.g + model.pens.a(iaway) - model.pens.d(ihome);
    else
        lambda_t_h = model.tries.c + model.tries.a(ihome) - model.tries.d(iaway);
        lambda_t_a = model.tries.c + model.tries.a(iaway) - model.tries.d(ihome);
        lambda_p_h = model.pens.c + model.pens.a(ihome) - model.pens.d(iaway);
        lambda_p_a = model.pens.c + model.pens.a(iaway) - model.pens.d(ihome);
    end

    conv_h = model.cons.p(ihome);
    conv_a = model.cons.p(iaway);
    
    htries = poissrnd(lambda_t_h,n,1);
    hpens  = poissrnd(lambda_p_h,n,1);
    hcons  = binornd(htries,conv_h);
    
    atries = poissrnd(lambda_t_a,n,1);
    apens  = poissrnd(lambda_p_a,n,1);
    acons  = binornd(atries,conv_a);
    
    score_home = 5 * htries + 3 * hpens + 2 * hcons;
    score_away = 5 * atries + 3 * apens + 2 * acons;
    
    if 0
    
        % Stats
        
        prob_home_win = mean(score_home > score_away);
        prob_away_win = mean(score_home < score_away);
        prob_draw     = mean(score_home == score_away);

        prob_home_loses_by_less_than_7 = mean(score_home < score_away & (score_away - score_home <= 7));
        prob_away_loses_by_less_than_7 = mean(score_away < score_home & (score_home - score_away <= 7));

        prob_home_scores_at_least_4_tries = mean(htries >= 4);
        prob_away_scores_at_leasgit_4_tries = mean(atries >= 4);
    
        % Print to screen

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