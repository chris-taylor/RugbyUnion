function data = loadGameData(filename,teams)

    if nargin < 2
        teams = {};
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
    data.teams     = union(data.hometeam, data.awayteam);
    
    % Filter out 'all-star' teams
    
    allstars = {'Lions'
                'New Zealand Maori'
                'World XV'
                'Barbarians'};
    
    loc1 = ~cellfun(@(c)ismember(c,allstars),data.hometeam);
    loc2 = ~cellfun(@(c)ismember(c,allstars),data.awayteam);
    
    data = filterStruct(data,loc1&loc2);
    
    % Only use data from 1 April 1992 (start of modern point system)
    
    data = between(data,'01-Apr-1992');
    
    % Select countries
    
    if ~isempty(teams)
        data = selectCountries(data,teams,true);
    end
    
    % Add regression matrix
    
    data = regressionMatrix(data);
    
end