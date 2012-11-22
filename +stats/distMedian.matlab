function result = distMedian(x,p)

    [x idx] = sort(x);
    p = p(idx);

    cp = cumsum(p) / sum(p);
    
    [junk min_idx] = min(abs(cp-0.5));
    
    result = x(min_idx);

end