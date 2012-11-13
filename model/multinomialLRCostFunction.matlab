function cost = multinomialLRCostFunction(prediction,actual)

    if ~all(size(prediction) == size(actual))
        error('Prediction and results not the same size')
    end
    
    N = size(actual,1);
    K = size(actual,2);
    cost = 0;
    
    for k = 1:K
        idx = actual(:,k);
        cost = cost - sum(actual(idx,k) .* log(prediction(idx,k)));
    end
    
    cost = cost / N;

end