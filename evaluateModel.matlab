function cost = evaluateModel(model,data)

    prediction = model.predict(data.X);
    
    prediction(prediction < 0) = 0;
    prediction(prediction > 1) = 1;
    
    cost = multinomialLRCostFunction(prediction,[data.homewin data.awaywin data.draw]);

end
