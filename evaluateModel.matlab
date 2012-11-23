function cost = evaluateModel(model,data)

    XH = data.X; XH(XH<0) = 0;
    XA =-data.X; XA(XA<0) = 0;

    prediction = model.predictHomeAdv(XH,XA);
    
    prediction(prediction < 0) = 0;
    prediction(prediction > 1) = 1;
    
    actual = [data.homewin, data.draw, data.awaywin];
    
    cost.logscore  = multinomialLRCostFunction(prediction,actual);
    cost.brier     = multinomialBrierScore(prediction,actual);
    cost.errorrate = multinomialErrorRate(prediction,actual);

end
