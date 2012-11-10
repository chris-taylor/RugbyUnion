function cnt = count(x)
%COUNT Return struct with fields 'vals' and 'counts', with the unique
%values in the input vector x and how often they occur.

    cnt.vals = unique(x(:));
    cnt.counts = zeros(size(cnt.vals));
    
    for ii = 1:length(cnt.vals)
        cnt.counts(ii) = sum(x == cnt.vals(ii));
    end

end