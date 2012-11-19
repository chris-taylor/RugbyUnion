function model = logisticRegression(y,X,lambda,w,bias)

    if nargin < 3
        lambda = 0;
    end
    
    if nargin < 4
        w = NaN;
    end
    
    if nargin < 5
        bias = true;
    end
    
    if bias
        maybeAddBias = @addones;
    else
        maybeAddBias = @(x) x;
    end
    
    X = maybeAddBias(X);
    
    f = @(theta) logisticRegressionCostFunction(y,X,lambda,w,theta);
    
    theta0 = 0.01 * randn(size(X,2),1);
    
    opts = optimset();
    opts.GradObj = 'on';
    
    keyboard
    
    thetamin = fminunc(f,theta0,opts);
    
    model.name = 'logisticRegression';
    model.theta = thetamin;
    model.lambda = lambda;
    model.predict = @(x) sigmoid(maybeAddBias(x) * model.theta);

end
