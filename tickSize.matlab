function tick = tickSize(odds)

    if odds < 1.01
        error('Odds must be greater than 1')
    elseif odds < 2
        tick = 0.01;
    elseif odds < 3
        tick = 0.02;
    elseif odds < 4
        tick = 0.05;
    elseif odds < 6
        tick = 0.1;
    elseif odds < 10
        tick = 0.2;
    elseif odds < 20
        tick = 0.5;
    elseif odds < 30
        tick = 1;
    elseif odds < 50
        tick = 2;
    elseif odds < 100
        tick = 5;
    elseif odds <= 1000
        tick = 10;
    else
        error('Odds must be less than or equal to 1000')
    end

end