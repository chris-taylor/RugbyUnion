function optimalLRLambda(train,test,lambdas)

    eta = log(2) / (7 * 365);

    nvals = length(lambdas);
    
    traincost = zeros(size(lambdas));
    testcost  = zeros(size(lambdas));
    trainerror = zeros(size(lambdas));
    testerror  = zeros(size(lambdas));
    trainbrier = zeros(size(lambdas));
    testbrier  = zeros(size(lambdas));
    
    for ii = 1:nvals
       
        model = logisticModel(train,lambdas(ii),eta);
        
        trainscores = evaluateModel(model,train);
        testscores  = evaluateModel(model,test);
        
        traincost(ii) = trainscores.logscore;
        testcost(ii)  = testscores.logscore;
        
        trainerror(ii) = trainscores.errorrate;
        testerror(ii)  = testscores.errorrate;
        
        trainbrier(ii) = trainscores.brier;
        testbrier(ii)  = testscores.brier;
        
    end
    
    % Log score plot
    
    figure;
    hold on;
    plot(log(lambdas),traincost,'b');
    plot(log(lambdas),testcost,'r');
    
    xlabel('Log(Lambda)')
    ylabel('Cost')
    title('LogScore(Lambdas)')
    legend({'Training set', 'Test set'})
    
    % Error rate plot
    
    figure;
    hold on;
    plot(log(lambdas),trainerror,'b');
    plot(log(lambdas),testerror,'r');
    
    xlabel('Log(Lambda)')
    ylabel('Cost')
    title('ErrorRate(Lambdas)')
    legend({'Training set', 'Test set'})
    
    % Brier score plot
    
    figure;
    hold on;
    plot(log(lambdas),trainbrier,'b');
    plot(log(lambdas),testbrier,'r');
    
    xlabel('Log(Lambda)')
    ylabel('Cost')
    title('BrierScore(Lambdas)')
    legend({'Training set', 'Test set'})
end