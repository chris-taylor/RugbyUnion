function poissonOptimalTimeWeighting(train,test,years)

    function val = fun(x)
        lambda = x(1);
        t_half = x(2);
        model = poissonRegression(train,t_half,lambda,min(test.date));
        val = -poissonMixtureLikelihood(model,test);
    end

    x0 = [2; 1];
    
    [xopt fval] = fminunc(@fun,x0);

    keyboard
    
    lambda = 1;
    t_now = min(test.date);

    nvals = length(years);
    
    traincost = zeros(size(years));
    testcost  = zeros(size(years));
    trainerror = zeros(size(years));
    testerror  = zeros(size(years));
    trainbrier = zeros(size(years));
    testbrier  = zeros(size(years));
    trainll = zeros(size(years));
    testll = zeros(size(years));
    
    for ii = 1:nvals
        
        model = poissonRegression(train,years(ii),lambda,t_now);
        
%         trainscores = evaluateModel(model,train);
%         testscores  = evaluateModel(model,test);
%         
%         traincost(ii) = trainscores.logscore;
%         testcost(ii)  = testscores.logscore;
%         
%         trainerror(ii) = trainscores.errorrate;
%         testerror(ii)  = testscores.errorrate;
%         
%         trainbrier(ii) = trainscores.brier;
%         testbrier(ii)  = testscores.brier;
        
        trainll(ii) = poissonMixtureLikelihood(model,train);
        testll(ii)  = poissonMixtureLikelihood(model,test);
        
    end
    
%     % Log score plot
%     
%     figure;
%     hold on;
%     plot(years,traincost,'b');
%     plot(years,testcost,'r');
%     
%     xlabel('Years')
%     ylabel('Cost')
%     title('LogScore(Years)')
%     legend({'Training set', 'Test set'})
%     grid on
%     
%     % Error rate plot
%     
%     figure;
%     hold on;
%     plot(years,trainerror,'b');
%     plot(years,testerror,'r');
%     
%     xlabel('Years')
%     ylabel('Cost')
%     title('ErrorRate(Years)')
%     legend({'Training set', 'Test set'})
%     grid on
%     
%     % Brier score plot
%     
%     figure;
%     hold on;
%     plot(years,trainbrier,'b');
%     plot(years,testbrier,'r');
%     
%     xlabel('Years')
%     ylabel('Cost')
%     title('BrierScore(Years)')
%     legend({'Training set', 'Test set'})
%     grid on
    
    % Log likelihood plot
    
    figure;
    hold on;
    plot(years,trainll,'b');
    plot(years,testll,'r');
    
    xlabel('T_{half}')
    ylabel('LogLikelihood')
    title('LogLikelihood(T_{half})')
    legend({'Training set', 'Test set'})
    grid on
    
    
end