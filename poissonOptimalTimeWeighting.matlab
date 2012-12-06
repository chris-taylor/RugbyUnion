function poissonOptimalTimeWeighting(train,test,years)

    nvals = length(years);
    
    traincost = zeros(size(years));
    testcost  = zeros(size(years));
    trainerror = zeros(size(years));
    testerror  = zeros(size(years));
    trainbrier = zeros(size(years));
    testbrier  = zeros(size(years));
    
    for ii = 1:nvals
        
        model = poissonModel(train,fix(now),years(ii));
        
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
    plot(years,traincost,'b');
    plot(years,testcost,'r');
    
    xlabel('Years')
    ylabel('Cost')
    title('LogScore(Years)')
    legend({'Training set', 'Test set'})
    
    % Error rate plot
    
    figure;
    hold on;
    plot(years,trainerror,'b');
    plot(years,testerror,'r');
    
    xlabel('Years')
    ylabel('Cost')
    title('ErrorRate(Years)')
    legend({'Training set', 'Test set'})
    
    % Brier score plot
    
    figure;
    hold on;
    plot(years,trainbrier,'b');
    plot(years,testbrier,'r');
    
    xlabel('Years')
    ylabel('Cost')
    title('BrierScore(Years)')
    legend({'Training set', 'Test set'})
    
    
end