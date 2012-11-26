function fixtures = getFixtures()
    
    games(1).home = 'Ireland';
    games(1).away = 'Argentina';

    games(2).home = 'France';
    games(2).away = 'Samoa';

    games(3).home = 'England';
    games(3).away = 'South Africa';

    games(4).home = 'Wales';
    games(4).away = 'New Zealand';

    games(5).home = 'Scotland';
    games(5).away = 'Tonga';

    games(6).home = 'Italy';
    games(6).away = 'Australia';
    
    for n = 1:6
        fixtures(n) = getFixture(games(n));
    end
    
end

function fixture = getFixture(game)

    fixture.home.team = game.home;
    fixture.away.team = game.away;
    
    switch game.home
        case {'Ireland','Argentina'}
            fixture.home.odds = [1.57 1.59];
            fixture.away.odds = [2.94 2.98];
        case {'France','Samoa'}
            fixture.home.odds = [1.14 1.15];
            fixture.away.odds = [8.4 14];
        case {'England','South Africa'}
            fixture.home.odds = [2.24 2.26];
            fixture.away.odds = [1.94 1.95];
        case {'Wales','New Zealand'}
            fixture.home.odds = [10.5 12];
            fixture.away.odds = [1.1 1.12];
        case {'Scotland','Tonga'}
            fixture.home.odds = [1.17 1.18];
            fixture.away.odds = [7.4 8];
        case {'Italy','Australia'}
            fixture.home.odds = [8.4 8.6];
            fixture.away.odds = [1.14 1.16];
        otherwise
            error('Fixture not found: %s v %s',game{1},game{2})
    end
    
end