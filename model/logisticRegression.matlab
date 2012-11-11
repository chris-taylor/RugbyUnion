function model = logisticRegression(y,X,lambda)

    if nargin < 3
        lambda = 0;
    end
    
    X = [repmat(1, size(X,1), 1) X];
    
    f = @(theta) logisticRegressionCostFunction(y,X,lambda,theta);
    
    theta0 = 0.01 * randn(size(X,2),1);
    
    opts = optimset();
    opts.GradObj = 'on';
    
    thetamin = fminunc(f,theta0,opts);
    
    model.name = 'logisticRegression';
    model.theta = thetamin;
    model.lambda = lambda;
    model.predict = @(x) sigmoid([repmat(1,size(x,1),1) x] * model.theta);

end
