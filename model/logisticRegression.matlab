function model = logisticRegression(y,X,lambda,w)

    if nargin < 3
        lambda = 0;
    end
    
    if nargin < 4
        w = NaN;
    end
    
    X = addones(X);
    
    f = @(theta) logisticRegressionCostFunction(y,X,lambda,w,theta);
    
    theta0 = 0.01 * randn(size(X,2),1);
    
    opts = optimset();
    opts.GradObj = 'on';
    
    thetamin = fminunc(f,theta0,opts);
    
    model.name = 'logisticRegression';
    model.theta = thetamin;
    model.lambda = lambda;
    model.predict = @(x) sigmoid(addones(x) * model.theta);

end
