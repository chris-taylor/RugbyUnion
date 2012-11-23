function data = loadSuperXVData()

    fname = 'data/superxv.csv';
    fid = fopen(fname);
    
    csv = textscan(fid,'%s %s %s %f %f %f %f %f %f %f %f','headerlines',1,'delimiter',',');
    
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

    % Need to explicitly correct score for some matches??

    % Correct 'Western Force' and 'W. Force' to 'Force'
    
    data.hometeam(strmatch('Western Force',data.hometeam)) = {'Force'};
    data.awayteam(strmatch('Western Force',data.awayteam)) = {'Force'};
    data.hometeam(strmatch('W. Force',data.hometeam)) = {'Force'};
    data.awayteam(strmatch('W. Force',data.awayteam)) = {'Force'};

    % Correction for conversions > tries (heuristic)

    loc = data.homecons > data.hometries;
    data.homecons(loc) = data.hometries(loc);
    loc = data.awaycons > data.awaytries;
    data.awaycons(loc) = data.awaytries(loc);
    
    % Correction for large number of drop goals (heuristic)
    
    data.homedrops(data.homedrops > 4) = 0;
    data.awaydrops(data.awaydrops > 4) = 0;
    
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