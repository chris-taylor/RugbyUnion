function data = loadInternationalsData()

    fname = 'data/espn_internationals.csv';
    fid = fopen(fname);
    
    if ispc
        csv = textscan(fid,'%s %s %s %f %f %f %f %f %f %f %f\r','headerlines',1,'delimiter',',');
    else
        csv = textscan(fid,'%s %s %s %f %f %f %f %f %f %f %f\r','headerlines',1,'delimiter',',');
    end
    
    fclose(fid);
    
    data.date = datenum(csv{1});
    data.hometeam = csv{2};
    data.awayteam = csv{3};
    data.hometries = csv{4};
    data.homepens = csv{5};
    data.homecons = csv{6};
    data.homedrops = csv{7};
    data.awaytries = csv{8};
    data.awaypens = csv{9};
    data.awaycons = csv{10};
    data.awaydrops = csv{11};

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
    
end