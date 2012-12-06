function y = predict(model,home,away,homeadv)

    if nargin < 4
        homeadv = true;
    end

    ihome = strmatch(home,model.teams);
    iaway = strmatch(away,model.teams);
    
    y = model.predict(ihome,iaway,homeadv);

end