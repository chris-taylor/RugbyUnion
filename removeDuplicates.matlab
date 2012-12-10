function data = removeDuplicates(data)
    n = length(data.date);
    idx = true(n,1);
    data = sortstruct(data,{'date','ihome','iaway'});
    for ii = 2:n
        if data.date(ii) == data.date(ii-1) && ...
                strcmp(data.hometeam{ii},data.hometeam{ii-1}) && ...
                strcmp(data.awayteam{ii},data.awayteam{ii-1})
            idx(ii) = false;
        end
    end
    data = filterStruct(data,idx);
end