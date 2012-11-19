function result = contains(str,pat)

    result = strfind(str,pat);
    keyboard
    result = ~isempty(result{1});

end