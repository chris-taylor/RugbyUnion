function s = sortstruct(s,fields,dir)

    if nargin < 3
        dir = 'ascend';
    end
    
    if ischar(fields)
        fields = {fields};
    end
    
    fields = fliplr(fields);
    
    names = fieldnames(s);
    
    for jj = 1:length(fields)
        field = fields{jj};
        [dummy, idx] = sort(s.(field), dir);
        for ii = 1:length(names)
            name = names{ii};
            try
                s.(name) = s.(name)(idx, :);
            catch
                % Do nothing
            end
        end
    end

end