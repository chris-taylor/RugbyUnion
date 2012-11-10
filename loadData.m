function data = loadData(filename)

    fid = fopen(filename,'r');

    fmt = '%s %s %d %d %s';

    csv = textscan(fid,fmt,'delimiter',',');

    data.date      = datenum(char(csv{1}));
    data.hometeam  = csv{2};
    data.homescore = csv{3};
    data.awayscore = csv{4};
    data.awayteam  = csv{5};
    
    fclose(fid);

end