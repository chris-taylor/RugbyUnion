function stats = aggregateTeams(data,teams)
    
    if nargin < 2
        teams = data.teams;
    end

    for ii = 1:length(teams)
       
        this.name = teams{ii};
        
        ihome = strmatch(this.name,data.hometeam);
        iaway = strmatch(this.name,data.awayteam);
        
        this.date     = [data.date(ihome); data.date(iaway)];
        this.opponent = [data.awayteam(ihome); data.hometeam(iaway)];
        this.pointsfor    = [data.homescore(ihome); data.awayscore(iaway)];
        this.pointsagainst = [data.awayscore(ihome); data.homescore(iaway)];
        
        this.triesfor = [data.hometries(ihome); data.awaytries(iaway)];
        this.triesagainst = [data.awaytries(ihome); data.hometries(iaway)];
        this.pensfor = [data.homepens(ihome); data.awaypens(iaway)];
        this.pensagainst = [data.awaypens(ihome); data.homepens(iaway)];
        this.consfor = [data.homecons(ihome); data.awaycons(iaway)];
        this.consagainst = [data.awaycons(ihome); data.homecons(iaway)];
        this.dropsfor = [data.homedrops(ihome); data.awaydrops(iaway)];
        this.dropsagainst = [data.awaydrops(ihome); data.homedrops(iaway)];
        
        this.home = [ones(size(ihome)); zeros(size(iaway))];
        
        stats(ii) = this;
        
    end

end