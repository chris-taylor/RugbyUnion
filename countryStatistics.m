function stats = countryStatistics()

    datafile = 'data/results.csv';
    
    countries = loadCountries();
    data = loadData(datafile);
    
    
    for ii = 1:length(countries)
       
        this.name = countries{ii};
        
        ihome = strmatch(this.name,data.hometeam);
        iaway = strmatch(this.name,data.awayteam);
        
        this.date     = [data.date(ihome); data.date(iaway)];
        this.opponent = [data.awayteam(ihome); data.hometeam(iaway)];
        this.score    = [data.homescore(ihome); data.awayscore(iaway)];
        this.opponentscore = [data.awayscore(ihome); data.homescore(iaway)];
        
        stats(ii) = this;
        
    end

end