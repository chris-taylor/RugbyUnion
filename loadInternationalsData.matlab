function data = loadInternationalsData()

    fname = 'data/espn_internationals.csv';
    fid = fopen(fname);
    
    csv = textscan(fid,'%s %s %s %s %f %f %f %f %f %f %f %f\r','headerlines',1,'delimiter',',');
    
    fclose(fid);
    
    data.date = datenum(csv{1});
    data.stadium = csv{2};
    data.hometeam = csv{3};
    data.awayteam = csv{4};
    data.hometries = csv{5};
    data.homepens = csv{6};
    data.homecons = csv{7};
    data.homedrops = csv{8};
    data.awaytries = csv{9};
    data.awaypens = csv{10};
    data.awaycons = csv{11};
    data.awaydrops = csv{12};

    % Only include the top 32 teams in the IRB rankings.
    
    irbTeams = {
        'New Zealand'
        'South Africa'
        'Australia'
        'France'
        'England'
        'Ireland'
        'Samoa'
        'Argentina'
        'Wales'
        'Italy'
        'Tonga'
        'Scotland'
        'Fiji'
        'Canada'
        'Japan'
        'United States of America'
        'Georgia'
        'Spain'
        'Romania'
        'Russia'
        'Portugal'
        'Uruguay'
        'Belgium'
        'Namibia'
        'Chile'
        'Poland'
        'Korea'
        'Hong Kong'
        'Germany'
        'Zimbabwe'
        'Ukraine'
        'Morocco'
        };
    
    idx = false(size(data.hometeam));
    for ii = 1:length(data.hometeam)
         if ismember(data.hometeam{ii},irbTeams) && ismember(data.awayteam{ii},irbTeams)
             idx(ii) = 1;
         end
    end
    
    data = filterStruct(data,idx);
    
    % Work out if there is a home advantage or not
    
    fid = fopen('data/stadiums.csv');
    csv = textscan(fid,'%s %s','delimiter',',');
    fclose(fid);
    stadiums = containers.Map;
    for i = 1:length(csv{1});
        stadiums(csv{1}{i}) = csv{2}{i};
    end
    
    n = length(data.hometeam);
    data.homeadv = zeros(n,1);
    for ii = 1:n
        if strcmp(stadiums(data.stadium{ii}), data.hometeam{ii})
            data.homeadv(ii) = 1;
        end
    end
    
    % Get total score and win/loss stats

    data.homescore = 5 * data.hometries + 3 * (data.homepens + data.homedrops) + 2 * data.homecons;
    data.awayscore = 5 * data.awaytries + 3 * (data.awaypens + data.awaydrops) + 2 * data.awaycons;
    
    data.homewin = data.homescore > data.awayscore;
    data.awaywin = data.homescore < data.awayscore;
    data.draw = data.homescore == data.awayscore;
    
    % Get team names
    
    data.teams = union(data.hometeam,data.awayteam);
    
    % Create selection matrix

    data.X = zeros(length(data.draw), length(data.teams));
    
    for ii = 1:length(data.draw)
       
        ihome = strmatch(data.hometeam{ii},data.teams,'exact');
        iaway = strmatch(data.awayteam{ii},data.teams,'exact');
        
        data.X(ii,ihome) = 1;
        data.X(ii,iaway) = -1;

    end
    
    % Create home/away indexes
    
    XH = data.X; XH(XH<0)=0;
    XA = -data.X; XA(XA<0)=0;
    
    data.ihome = sum(cumsum(fliplr(XH),2),2); % takes the selection matrix and converts to team indexes
    data.iaway = sum(cumsum(fliplr(XA),2),2); % (as above)
    
    % Sort and remove duplicates
    
    data = removeDuplicates(data);
    
end