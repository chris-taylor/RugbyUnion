function [fval grad] = logisticRegressionCostFunction(y,X,lambda,theta)

    m = size(X,1);

    h = sigmoid(X * theta);
    theta(1) = 0;   % don't penalise the bias term
    
    fval = - sum(y .* log(h) + (1-y) .* log(1-h))/m + lambda/m * sum(theta.^2);
    grad = X' * (h - y)/m + lambda/m * theta;

end