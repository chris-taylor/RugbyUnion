function y = predict(model,home,away)

    ihome = strmatch(home,model.countries);
    iaway = strmatch(away,model.countries);
    
    X = zeros(1, length(model.countries));
    
    X(ihome) = 1;
    X(iaway) = -1;
    
    y = model.predict(X);

end