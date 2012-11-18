function [fval grad] = logisticRegressionCostFunction(y,X,lambda,w,theta)

    if nargin < 5
        w = NaN;
    end

    m = size(X,1);

    h = sigmoid(X * theta);
    theta(1) = 0;   % don't penalise the bias term
    
    if isnan(w)
        fval = - sum(y .* log(h) + (1-y) .* log(1-h))/m + lambda/m * sum(theta.^2);
        grad = X' * (h - y)/m + lambda/m * theta;
    else
        fval = - sum(w .* (y .* log(h) + (1-y) .* log(1-h))) + lambda * sum(theta.^2);
        grad = bsxfun(@times,w,X)' * (h-y) + lambda * theta;
    end

end