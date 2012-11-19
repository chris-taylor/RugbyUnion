function model = logisticModel(data,lambda,eta)
%LOGISTICMODEL Use logistic regression to create a forecasting model for
%the result of rugby union internationals. The countries input specifies
%which teams you are interested in creating a forecast for. The useothers
%input tells the model whether to use games vs other teams or not.

    if nargin < 2
        lambda = 0;
    end
    
    if nargin < 3
        eta = 0;
    end
    
    weights = exp( -eta * (datenum(date) - data.date) );
    
    % Model with home advantage
    
    homeWinH = logisticRegression(data.homewin,data.X,lambda,weights);
    awayWinH = logisticRegression(data.awaywin,data.X,lambda,weights);
    drawH    = logisticRegression(data.draw,data.X,lambda,weights);
    
    % Model with no home advantage
    
    homeWinN = logisticRegression(data.homewin,data.X,lambda,weights,false);
    awayWinN = logisticRegression(data.awaywin,data.X,lambda,weights,false);
    drawN    = logisticRegression(data.draw,data.X,lambda,weights,false);
    
    
    model.countries = data.countries;
    model.adv.homeWin = homeWinH;
    model.adv.awayWin = awayWinH;
    model.adv.draw    = drawH;
    model.noAdv.homeWin = homeWinN;
    model.noAdv.awayWin = awayWinN;
    model.noAdv.draw    = drawN;
    model.predictHomeAdv   = @predictorH;
    model.predictNoHomeAdv = @predictorN;
    
    function y = predictorH(x)
        x = addones(x);
        y(:,1) = sigmoid(x * model.adv.homeWin.theta);
        y(:,2) = sigmoid(x * model.adv.awayWin.theta);
        y(:,3) = sigmoid(x * model.adv.draw.theta);
        y = bsxfun(@rdivide,y,sum(y,2));
    end
    
    function y = predictorN(x)
        y(:,1) = sigmoid(x * model.noAdv.homeWin.theta);
        y(:,2) = sigmoid(x * model.noAdv.awayWin.theta);
        y(:,3) = sigmoid(x * model.noAdv.draw.theta);
        y = bsxfun(@rdivide,y,sum(y,2));
    end

end