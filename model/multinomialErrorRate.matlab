function errorrate = multinomialErrorRate(prediction,actual)

    [junk idx] = max(prediction,[],2);
    
    N = size(actual,1);
    errorrate = 0;
    
    for n = 1:N
        if ~actual(n,idx(n))
            errorrate = errorrate + 1/N;
        end
    end

end