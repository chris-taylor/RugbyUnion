function new = filterStruct(old,idx)

    fnames = fieldnames(old);
    n = length(idx);
    
    for ii = 1:length(fnames)
        name = fnames{ii};
        if size(old.(name), 1) == n
            x = old.(name);
            new.(name) = x(idx,:);
        else
            new.(name) = old.(name);
        end
    end

end