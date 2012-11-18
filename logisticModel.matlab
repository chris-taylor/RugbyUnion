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
    
    homeWin = logisticRegression(data.homewin,data.X,lambda,weights);
    awayWin = logisticRegression(data.awaywin,data.X,lambda,weights);
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
        y(:,3) = sigmoid(x * model.draw.theta);
        y = bsxfun(@rdivide,y,sum(y,2));
%         max(1 - sum(y,2), 0);
    end

end