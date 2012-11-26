function data = regressionMatrix(data)
    
    n = size(data.date,1);

    data.homewin   = data.homescore > data.awayscore;
    data.draw      = data.homescore == data.awayscore;
    data.awaywin   = data.homescore < data.awayscore;
    
    data.X = zeros(n, length(data.teams));
    
    for ii = 1:n
       
        ihome = strmatch(data.hometeam{ii},data.teams,'exact');
        iaway = strmatch(data.awayteam{ii},data.teams,'exact');
        
        data.X(ii,ihome) = 1;
        data.X(ii,iaway) = -1;

    end

end