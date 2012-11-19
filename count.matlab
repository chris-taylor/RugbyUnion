function cnt = count(x)
%COUNT Return struct with fields 'vals' and 'counts', with the unique
%values in the input vector x and how often they occur.

    cnt.vals = unique(x(:));
    cnt.counts = zeros(size(cnt.vals));
    
    switch class(x)
        case {'double','single'}
            for ii = 1:length(cnt.vals)
                cnt.counts(ii) = sum(x == cnt.vals(ii));
            end
        case {'cell'}
            for ii = 1:length(cnt.vals)
                cnt.counts(ii) = numel(strmatch(cnt.vals{ii},x,'exact'));
            end
        otherwise
            error(['Unsupported class: ' class(x)])
    end
    
    cnt.freqs = cnt.counts / numel(x);

end