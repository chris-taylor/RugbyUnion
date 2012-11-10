function data = between(data,from,to)

    if nargin < 3
        to = date;
    end
    
    from = datenum(from);
    to   = datenum(to);
    
    loc = data.date >= from & data.date <= to;
    
    data.date = data.date(loc);
    data.hometeam = data.hometeam(loc);
    data.homescore = data.homescore(loc);
    data.awayscore = data.awayscore(loc);
    data.awayteam = data.awayteam(loc);

end