function data = selectCountries(data,countries,or)
%SELECTCOUNTRIES Take a subset of a data set, only including games which
%involve the countries in the cell array 'countries'. If the input 'or' is
%true, then games which include at least one of the relevant countries are
%included. If it is false, then games have to be between two of the
%relevant countries.

    if nargin < 3
        or = false;
    end
    
    loc1 = cellfun(@(c) ismember(c,countries), data.hometeam);
    loc2 = cellfun(@(c) ismember(c,countries), data.awayteam);
    
    if or
        loc = loc1 | loc2;
    else
        loc = loc1 & loc2;
    end
    
    data = filterStruct(data,loc);

end