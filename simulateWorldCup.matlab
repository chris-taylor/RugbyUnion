function result = simulateWorldCup(model,host,teams)

    % Default teams
    if nargin < 3
        teams = {
            'New Zealand'
            'South Africa'
            'Australia'
            'France'
            'England'
            'Ireland'
            'Samoa'
            'Argentina'
            'Wales'
            'Italy'
            'Tonga'
            'Scotland'
            'Fiji'
            'Canada'
            'Japan'
            'United States of America'
            'Georgia'
            'Spain'
            'Romania'
            'Russia'
        };
    end

    % Host idx
    ihost = strmatch(host,model.teams,'exact');

    switch class(teams{1})
        
        case 'cell'
            % Group assignments already taken care of
            groups_ = teams;
            for ii = 1:4
                for jj = 1:5
                    groups{ii}(jj) = strmatch(groups_{ii}{jj},model.teams,'exact'); %#ok
                end
            end
            
        case 'char'
            % Need to assign teams to groups
            for ii = 1:length(teams)
                teamidxs(ii) = strmatch(teams{ii},model.teams,'exact'); %#ok
            end

            groups = {[],[],[],[]};

            for grp = 1:4
                groups{grp}(1) = teamidxs(grp);
            end

            for rank = 1:4
                idxs = randsample(1:4,4);
                for grp = 1:4
                    groups{grp}(rank+1) = teamidxs(4*rank + idxs(grp));
                end
            end
            
        otherwise
            disp('Unknown class')
            keyboard
            
    end
    
    A = simulateWorldCupGroup(model,groups{1},ihost);
    B = simulateWorldCupGroup(model,groups{2},ihost);
    C = simulateWorldCupGroup(model,groups{3},ihost);
    D = simulateWorldCupGroup(model,groups{4},ihost);
    
    result = simulateKnockout(model,[B.winner, A.runnerup, C.winner, D.runnerup, A.winner, B.runnerup, D.winner, C.runnerup],ihost);
    
    result.A = A;
    result.B = B;
    result.C = C;
    result.D = D;

end