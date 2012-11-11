function out = regressionMatrix(data)
    
    n = size(data.date,1);

    out.countries = union(data.hometeam, data.awayteam);

    out.date    = data.date;
    out.homewin = data.homescore > data.awayscore;
    out.draw    = data.homescore == data.awayscore;
    out.awaywin = data.homescore < data.awayscore;
    
    out.X = zeros(n, length(out.countries));
    
    for ii = 1:n
       
        ihome = strmatch(data.hometeam{ii},out.countries,'exact');
        iaway = strmatch(data.awayteam{ii},out.countries,'exact');
        
        out.X(ii,ihome) = 1;
        out.X(ii,iaway) = -1;
        
    end

end