function data = regressionMatrix(data)
    
    n = size(data.date,1);

    data.countries = union(data.hometeam, data.awayteam);
    data.homewin   = data.homescore > data.awayscore;
    data.draw      = data.homescore == data.awayscore;
    data.awaywin   = data.homescore < data.awayscore;
    
    data.X = zeros(n, length(data.countries));
    
    for ii = 1:n
       
        ihome = strmatch(data.hometeam{ii},data.countries,'exact');
        iaway = strmatch(data.awayteam{ii},data.countries,'exact');
        
        data.X(ii,ihome) = 1;
        data.X(ii,iaway) = -1;

    end

end