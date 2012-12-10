function backtest(data,events)
%Backtest trading model.

    t_half = 2.25;
    lambda = 1.33;
    
    df = 0.95;

    capital = 100 * ones(length(events)+1,1);
    
    for ii = 1:length(events)
       
        ev = events(ii);
        
        % Display event
        fprintf('--------------------\n')
        fprintf('Date:    %s\n',datestr(ev.scheduled_off))
        fprintf('Home:    %s\n',ev.home)
        fprintf('Away:    %s\n',ev.away)
        
        % Get back/lay amounts
        names = {ev.selection.name};
        ihome = strmatch(ev.home, names);
        iaway = strmatch(ev.away, names);
        idraw = strmatch('Draw', names);
        
        back(1) = ev.selection(ihome).back;
        back(2) = ev.selection(iaway).back;
        back(3) = ev.selection(idraw).back;
        
        lay(1) = ev.selection(ihome).lay;
        lay(2) = ev.selection(iaway).lay;
        lay(3) = ev.selection(idraw).lay;
        
        % Build predictive model
        model = poissonRegression(data,t_half,lambda,ev.scheduled_off);
        
        % Get predictions
        prob = predict(model, ev.home, ev.away);
        
        % Get bet sizes
        stake = kellyCriterionMultipleOutcomes(prob,back,lay,capital(ii));
        
        % Half-kelly betting
        stake = stake / 2;
        
        
        % Evaluate winnings
        mid  = (back + lay) / 2;
        spd  = lay - back;
        
        win_flag = logical([ev.selection.win_flag]);
        winnings = sum(stake .* mid .* win_flag - abs(stake) .* (spd/2) - stake);
        
        if winnings > 0
            winnings = df * winnings;
        end
        
        % Disp
        fprintf('P(Home): %4.1f%% (market), %4.1f%% (model)\n',100/mid(1),100*prob(1))
        fprintf('P(Away): %4.1f%% (market), %4.1f%% (model)\n',100/mid(2),100*prob(2))
        fprintf('P(Draw): %4.1f%% (market), %4.1f%% (model)\n',100/mid(3),100*prob(3))
        fprintf('S(Home): %.1f\n',stake(1))
        fprintf('S(Away): %.1f\n',stake(2))
        fprintf('S(Draw): %.1f\n',stake(3))
        
        if win_flag(1)
            fprintf('Result:  %s\n',ev.home)
        elseif win_flag(2)
            fprintf('Result:  %s\n',ev.away)
        elseif win_flag(3)
            fprintf('Result:  Draw\n')
        end
        
        fprintf('Winnings: %.2f\n',winnings);
        
        capital(ii+1) = capital(ii) + winnings;
        
    end
    
    plot(capital);
    xlabel('Number of games')
    ylabel('Capital (GBP)')
    grid on

end