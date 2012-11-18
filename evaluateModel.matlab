function cost = evaluateModel(model,data)

    prediction = model.predict(data.X);
    
    prediction(prediction < 0) = 0;
    prediction(prediction > 1) = 1;
    
    actual = [data.homewin, data.awaywin, data.draw];
    
    cost.logscore  = multinomialLRCostFunction(prediction,actual);
    cost.brier     = multinomialBrierScore(prediction,actual);
    cost.errorrate = multinomialErrorRate(prediction,actual);

end
