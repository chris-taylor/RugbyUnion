function data = between(data,from,to)

    if nargin < 3
        to = date;
    end
    
    from = datenum(from);
    to   = datenum(to);
    
    loc = data.date >= from & data.date <= to;
    
    data = filterStruct(data,loc);

end