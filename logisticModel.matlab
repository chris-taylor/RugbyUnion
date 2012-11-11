function model = logisticModel(data,lambda)
%LOGISTICMODEL Use logistic regression to create a forecasting model for
%the result of rugby union internationals. The countries input specifies
%which teams you are interested in creating a forecast for. The useothers
%input tells the model whether to use games vs other teams or not.

    if nargin < 2
        lambda = 1;
    end
    
    homeWin = logisticRegression(data.homewin,data.X,lambda);
    awayWin = logisticRegression(data.awaywin,data.X,lambda);
    draw    = logisticRegression(data.draw,data.X,lambda);
    
    model.countries = data.countries;
    model.homeWin = homeWin;
    model.awayWin = awayWin;
    model.draw    = draw;
    model.predict = @predictor;
    
    function y = predictor(x)
        x = addones(x);
        y(:,1) = sigmoid(x * model.homeWin.theta);
        y(:,2) = sigmoid(x * model.awayWin.theta);
        y(:,3) = 1 - sum(y,2);
    end

end

function model = trimModel(model,loc)

    theta = model.theta(2:end);
    
    model.theta   = [model.theta(1); theta(loc)];
    model.predict = @(x)sigmoid(addones(x) * model.theta);

end