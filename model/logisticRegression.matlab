function model = logisticRegression(y,X,lambda)

    if nargin < 3
        lambda = 0;
    end
    
    X = addones(X);
    
    f = @(theta) logisticRegressionCostFunction(y,X,lambda,theta);
    
    theta0 = 0.01 * randn(size(X,2),1);
    
    opts = optimset();
    opts.GradObj = 'on';
    
    thetamin = fminunc(f,theta0,opts);
    
    model.name = 'logisticRegression';
    model.theta = thetamin;
    model.lambda = lambda;
    model.predict = @(x) sigmoid(addones(x) * model.theta);

end
