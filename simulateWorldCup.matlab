function result = simulateWorldCup(model,teams)

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
    
    A = simulateWorldCupGroup(model,groups{1});
    B = simulateWorldCupGroup(model,groups{2});
    C = simulateWorldCupGroup(model,groups{3});
    D = simulateWorldCupGroup(model,groups{4});
    
    result = simulateKnockout(model,[B.winner, A.runnerup, C.winner, D.runnerup, A.winner, B.runnerup, D.winner, C.runnerup]);
    
    result.A = A;
    result.B = B;
    result.C = C;
    result.D = D;

end