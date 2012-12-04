function stats = analyseWorldCupResults(results,model)
    
    winner = [results.winner];
    second = [results.second];
    third  = [results.third];
    fourth = [results.fourth];
    
    qf = {results.quarterFinalists};
    sf = {results.semiFinalists};
    f  = {results.finalists};
    p  = {results.playoffs};
    
    for ii = 1:length(model.teams);
        
        stats(ii).team = model.teams{ii};
        stats(ii).pwin = mean(winner == ii);
        stats(ii).psecond = mean(second == ii);
        stats(ii).pthird = mean(third == ii);
        stats(ii).pfourth = mean(fourth == ii);
        stats(ii).pQuarterFinal = mean(cellfun(@(x)ismember(ii,x),qf));
        stats(ii).pSemiFinal = mean(cellfun(@(x)ismember(ii,x),sf));
        stats(ii).pFinal = mean(cellfun(@(x)ismember(ii,x),f));
        stats(ii).pPlayoff = mean(cellfun(@(x)ismember(ii,x),p));
        
    end

end