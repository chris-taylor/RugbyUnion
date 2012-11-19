function out = split(str,char)

    out = regexp(str,char,'split');
    
    if length(out) == 1 && isempty(out{1})
        out = {};
    end

end