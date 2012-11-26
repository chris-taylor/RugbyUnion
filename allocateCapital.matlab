function bets = allocateCapital(bets,capital,method)

    positiveExpectation = [bets.expectation] > 0;
    
    switch method
        
        case 'equal'
    
            % Allocate capital equally
            
            N = sum(positiveExpectation);

            for n = 1:length(bets)
                if positiveExpectation(n)
                    bets(n).capital = capital / N;
                else
                    bets(n).capital = 0;
                end
            end
            
        case 'ir'
    
            % Allocate capital in proportion to IR

            irTotal = sum([bets(positiveExpectation).ir]);

            for n = 1:length(bets)
                if positiveExpectation(n)
                    bets(n).capital = capital * bets(n).ir / irTotal;
                else
                    bets(n).capital = 0;
                end
            end
            
        case 'adjustedir'
    
            % Allocate capital in proportion to IR / stdev

            irTotal = sum([bets(positiveExpectation).ir] ./ [bets(positiveExpectation).stdev]);

            for n = 1:length(bets)
                if positiveExpectation(n)
                    bets(n).capital = capital * bets(n).ir / bets(n).stdev / irTotal;
                else
                    bets(n).capital = 0;
                end
            end
            
        case 'm2mir'
    
            % Allocate capital in proportion to mark-to-market IR

            irTotal = sum([bets(positiveExpectation).marketir]);

            for n = 1:length(bets)
                if positiveExpectation(n)
                    bets(n).capital = capital * bets(n).marketir / irTotal;
                else
                    bets(n).capital = 0;
                end
            end
            
        case 'adjustedir'
    
            % Allocate capital in proportion to mark-to-market IR / stdev

            total = sum([bets(positiveExpectation).marketir] ./ [bets(positiveExpectation).marketstdev]);

            for n = 1:length(bets)
                if positiveExpectation(n)
                    bets(n).capital = capital * bets(n).marketir / bets(n).marketstdev / total;
                else
                    bets(n).capital = 0;
                end
            end
            
        case 'kelly'
            
            % Allocate capital according to the kelly criterion
            
            p  = [bets.prob];
            df = 0.95;
            
            for n = 1:length(bets)
               
                f = (p(n) * df * bets(n).win + (1-p(n)) * bets(n).lose) / abs(df * bets(n).win * bets(n).lose);
                
                if f > 0
                    bets(n).capital = capital * f;
                else
                    bets(n).capital = 0;
                end
                
            end
            
        case 'halfkelly'
            
            % Allocate capital according to the helf-kelly criterion
            
            p  = [bets.prob];
            df = 0.95;
            
            for n = 1:length(bets)
               
                f = (1/2) * (p(n) * df * bets(n).win + (1-p(n)) * bets(n).lose) / abs(df * bets(n).win * bets(n).lose);
                
                if f > 0
                    bets(n).capital = capital * f;
                else
                    bets(n).capital = 0;
                end
                
            end
            
            
    end
      
end