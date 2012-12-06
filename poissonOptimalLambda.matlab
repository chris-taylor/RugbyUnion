function poissonOptimalLambda(train,test,lambdas)

    t_half = inf;
    t_now  = min(test.date);

    nvals = length(lambdas);
    
    traincost = zeros(size(lambdas));
    testcost = zeros(size(lambdas));
    trainerror = zeros(size(lambdas));
    testerror = zeros(size(lambdas));
    trainbrier = zeros(size(lambdas));
    testbrier = zeros(size(lambdas));
    trainll = zeros(size(lambdas));
    testll = zeros(size(lambdas));
    
    for ii = 1:nvals
       
%         model = poissonModel(train,t_half,lambdas(ii),t_now);
        model = poissonRegression(train,t_half,lambdas(ii),t_now);
        
        trainscores = evaluateModel(model,train);
        testscores  = evaluateModel(model,test);
        
        traincost(ii) = trainscores.logscore;
        testcost(ii)  = testscores.logscore;
        
        trainerror(ii) = trainscores.errorrate;
        testerror(ii)  = testscores.errorrate;
        
        trainbrier(ii) = trainscores.brier;
        testbrier(ii)  = testscores.brier;
        
        trainll(ii) = poissonMixtureLikelihood(model,train,true);
        testll(ii)  = poissonMixtureLikelihood(model,test,true);
        
    end
    
    % Log score plot
    
    figure;
    hold on;
    plot(log(lambdas),traincost,'b');
    plot(log(lambdas),testcost,'r');
    
    xlabel('Log(Lambda)')
    ylabel('Cost')
    title('LogScore(Lambda)')
    legend({'Training set', 'Test set'})
    
    % Error rate plot
    
    figure;
    hold on;
    plot(log(lambdas),trainerror,'b');
    plot(log(lambdas),testerror,'r');
    
    xlabel('Log(Lambda)')
    ylabel('Cost')
    title('ErrorRate(Lambda)')
    legend({'Training set', 'Test set'})
    
    % Brier score plot
    
    figure;
    hold on;
    plot(log(lambdas),trainbrier,'b');
    plot(log(lambdas),testbrier,'r');
    
    xlabel('Log(Lambda)')
    ylabel('Cost')
    title('BrierScore(Lambda)')
    legend({'Training set', 'Test set'})
    
    % Log likelihood plot
    
    figure;
    hold on;
    plot(log(lambdas),trainll,'b');
    plot(log(lambdas),testll,'r');
    
    xlabel('Log(Lambda)')
    ylabel('LogLikelihood')
    title('LogLikelihood(Lambda)')
    legend({'Training set', 'Test set'})
end