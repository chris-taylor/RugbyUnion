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
    
    homeWin = logisticRegression(data.homewin,data.X,lambda,weights);
    awayWin = logisticRegression(data.awaywin,data.X,lambda,weights);
    draw    = logisticRegression(data.draw,abs(data.X),lambda,weights);
    
    model.teams = data.teams;
    model.homeWin = homeWin;
    model.awayWin = awayWin;
    model.draw    = draw;
    model.predictHomeAdv   = @predictorAdv;
    model.predictNoHomeAdv = @predictorNoAdv;
    
    function y = predictorAdv(xh,xa)
        x = addones(xh-xa);
        y(:,1) = sigmoid(x * model.homeWin.theta);
        y(:,2) = sigmoid(abs(x) * model.draw.theta);
        y(:,3) = sigmoid(x * model.awayWin.theta);
        y = bsxfun(@rdivide,y,sum(y,2));
    end
    
    function y = predictorNoAdv(xh,xa)
        x = xh - xa;
        y(:,1) = sigmoid(addzeros(x) * model.homeWin.theta);
        y(:,2) = sigmoid(addones(abs(x)) * model.draw.theta);
        y(:,3) = sigmoid(addzeros(x) * model.awayWin.theta);
        y = bsxfun(@rdivide,y,sum(y,2));
    end

end