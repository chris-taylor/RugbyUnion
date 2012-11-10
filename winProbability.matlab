function out = winProbability(data,smooth)
    
    if nargin < 2
        smooth = 0;
    end

    countries = {data.name};
    
    out.pwin  = NaN(length(countries));
    out.plose = NaN(length(countries));
    out.pdraw = NaN(length(countries));
    
    for ii = 1:length(countries)
        
        d = data(ii);
        
        for jj = 1:length(countries)
            
            if jj == ii
                continue
            end
            
            idx = strmatch(countries{jj},d.opponent,'exact');
            
            win  = d.score(idx) > d.opponentscore(idx);
            lose = d.score(idx) < d.opponentscore(idx);
            draw = d.score(idx) == d.opponentscore(idx);
            
            x = smoothmean([win draw lose],smooth);
            
            out.pwin(ii,jj)  = x(1);
            out.pdraw(ii,jj) = x(2);
            out.plose(ii,jj) = x(3);
            
        end
    end

end

function result= smoothmean(x,k)
    result = (sum(x) + k) / (size(x,1) + size(x,2) * k);
end