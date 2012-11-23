function y = predict(model,home,away,homeadv)

    if nargin < 4
        homeadv = true;
    end

    ihome = strmatch(home,model.teams);
    iaway = strmatch(away,model.teams);
    
    XH = zeros(1, length(model.teams));
    XA = zeros(1, length(model.teams));
    
    XH(ihome) = 1;
    XA(iaway) = 1;
    
    if homeadv
        y = model.predictHomeAdv(XH,XA);
    else
        y = model.predictNoHomeAdv(XH,XA);
    end

end