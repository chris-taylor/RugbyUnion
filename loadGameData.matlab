function data = loadGameData(filename,countries)

    if nargin < 2
        countries = {};
    end

    fid = fopen(filename,'r');

    fmt = '%s %s %d %d %s';

    csv = textscan(fid,fmt,'delimiter',',','headerlines',1);
    
    fclose(fid);

    data.date      = datenum(char(csv{1}));
    data.hometeam  = csv{2};
    data.homescore = double(csv{3});
    data.awayscore = double(csv{4});
    data.awayteam  = csv{5};
    data.countries = union(data.hometeam, data.awayteam);
    
    % Filter out 'all-star' teams
    
    allstars = {'Lions'
                'New Zealand Maori'
                'World XV'
                'Barbarians'};
    
    loc = ~cellfun(@(c)ismember(c,allstars),data.countries);
    
    data = filterStruct(data,loc);
    
    % Only use data from 1 April 1992 (start of modern point system)
    
    data = between(data,'01-Apr-1992');
    
    % Select countries
    
    if ~isempty(countries)
        data = selectCountries(data,countries,true);
    end
    
    % Add regression matrix
    
    data = regressionMatrix(data);
    
end