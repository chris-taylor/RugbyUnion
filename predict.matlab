function y = predict(model,home,away,homeadv)

    if nargin < 4
        homeadv = true;
    end

    ihome = strmatch(home,model.countries);
    iaway = strmatch(away,model.countries);
    
    X = zeros(1, length(model.countries));
    
    X(ihome) = 1;
    X(iaway) = -1;
    
    if homeadv
        y = model.predictHomeAdv(X);
    else
        y = model.predictNoHomeAdv(X);
    end

end