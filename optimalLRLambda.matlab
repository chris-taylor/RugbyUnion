function optimalLRLambda(train,test,lambdas)

    nvals = length(lambdas);
    
    traincost = zeros(size(lambdas));
    testcost  = zeros(size(lambdas));
    
    for ii = 1:nvals
       
        model = logisticModel(train,lambdas(ii));
        
        traincost(ii) = evaluateModel(model,train);
        testcost(ii)  = evaluateModel(model,test);
        
    end
    
    gca;
    hold on;
    semilogx(lambdas,traincost,'b');
    semilogx(lambdas,testcost,'r');
    
    xlabel('Lambda')
    ylabel('Cost')
    title('C = Cost(Lambda)')
    legend({'Training set', 'Test set'})

end