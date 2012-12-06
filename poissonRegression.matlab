function model = poissonRegression(data,t_half,v,t)

    % Weights
    if nargin < 2
        t_half = 1;
    end
    if nargin < 3
        v = 10;
    end
    if nargin < 4
        t = fix(now);
    end
    
    delta_t = t - data.date;
    eta = log(2) / (365 * t_half);
    wts = exp(-eta * delta_t);
    
    % Home/away selection matrices
    XH = data.X;  XH(XH<0) = 0;
    XA = -data.X; XA(XA<0) = 0;
    
    iAdv  = ones(size(data.X, 1), 1);
    iHome = sum(cumsum(fliplr(XH),2),2); % takes the selection matrix and converts to team indexes
    iAway = sum(cumsum(fliplr(XA),2),2); % (as above)
    
    % Create model
    triesModel       = fitPoisson(data.hometries, data.awaytries, iAdv, iHome, iAway, wts, v);
    penaltiesModel   = fitPoisson(data.homepens + data.homedrops, data.awaypens + data.awaydrops, iAdv, iHome, iAway, wts, v);
    conversionsModel = fitConversions(data.hometries, data.homecons, data.awaytries, data.awaycons, iHome, iAway);
    
    model.tries = triesModel;
    model.pens  = penaltiesModel;
    model.cons  = conversionsModel;
    model.teams = data.teams;
    model.predictHomeAdv   = @predictHomeAdv;
    model.predictNoHomeAdv = @predictNoHomeAdv;
    
    function p = predictHomeAdv(XH,XA)
        p = predict(XH,XA,true);
    end

    function p = predictNoHomeAdv(XH,XA)
        p = predict(XH,XA,false);
    end
    
    function p = predict(XH,XA,homeadv)
        opts.homeadv = homeadv;
        iHome = sum(cumsum(fliplr(XH),2),2); % takes the selection matrix and converts to team indexes
        iAway = sum(cumsum(fliplr(XA),2),2); % (as above)
    
        [th ph ch ta pa ca] = getPoissonRegressionParameters(model,iHome,iAway,opts);
        
        n = length(th);
        [x y] = ndgrid(0:150);
        p = zeros(n,3);
        
        scores = (0:150)';
        
        ihomewin = x > y;
        idraw    = x == y;
        iawaywin = x < y;
        
        for ii = 1:n
            probhome = poissonMixturePdf(scores,th(ii),ph(ii),ch(ii));
            probaway = poissonMixturePdf(scores,ta(ii),pa(ii),ca(ii));
            
            P = kron(probhome, probaway');
        
            p(ii,1) = sum(sum(P(ihomewin)));
            p(ii,2) = sum(sum(P(idraw)));
            p(ii,3) = sum(sum(P(iawaywin)));
        end
        
%         p = real(p);
        
    end

end

function model = fitConversions(ht,hc,at,ac,iHome,iAway)

    n = max([iHome; iAway]);
    
    for ii = 1:n
        ntries(ii) = sum(ht(iHome==ii)) + sum(at(iAway==ii)); %#ok
        ncons(ii)  = sum(hc(iHome==ii)) + sum(ac(iAway==ii)); %#ok
    end
    
    model.p = (ncons ./ ntries)';

end

function model = fitPoisson(x,y,iAdv,iHome,iAway,w,v)

    debug = false;

    n = max([iHome; iAway]); % this line is a bit dodgy - what if a team doesn't appear in dataset?
    
    c = mean([x;y]);
    g = mean((x-y)/2);
    a = zeros(n,1);
    d = zeros(n,1);
    
    theta0 = [c; g; a; d];
    
    f = @(theta) negativeLL(n,theta,iAdv,iHome,iAway,x,y,w,v);
    opts = optimset();
    opts.GradObj = 'on';
    opts.Display = 'iter';
    
    if debug
        [fval grad1] = negativeLL(n,theta0,iAdv,iHome,iAway,x,y,w,v);
        grad2 = numericalGrad(f, theta0);
        figure; bar(grad1 - grad2)
        keyboard
    end
    
    theta = fminunc(f,theta0,opts);
    
    model.c = theta(1);
    model.g = theta(2);
    model.a = theta(3:n+2);
    model.d = theta(n+3:2*n+2);

end

function [f grad] = negativeLL(n,theta,iAdv,iHome,iAway,x,y,w,v)

    % Unpack params
    c = theta(1);           % mean scoring rate
    g = theta(2);           % home advantage
    a = theta(3:n+2);       % attacking team
    d = theta(n+3:2*n+2);   % defending team
    
    W = sum(w);             % sum of weights
    
    % Scoring rates for each game
    lambda = exp(c + g.*iAdv + a(iHome) - d(iAway));
    mu     = exp(c - g.*iAdv + a(iAway) - d(iHome));

    % Value
    f = sum(w .* (-lambda - mu + x .* log(lambda) + y .* log(mu))) / W;
    
    % Gradient
    dL_dc = sum(w .* (-lambda+x-mu+y));
    dL_dg = sum(w .* (-lambda+x+mu-y) .* iAdv);
    dL_da = zeros(size(a));
    dL_dd = zeros(size(d));
    
    for i = 1:length(dL_da)
        i1 = iHome == i;
        i2 = iAway == i;
        dL_da(i) = sum(w .* ((-lambda+x).*i1 + (-mu+y) .* i2));
        dL_dd(i) = sum(w .* ((lambda-x).*i2 + (mu-y).*i1)); 
    end
    
    grad = [dL_dc; dL_dg; dL_da; dL_dd] / W;
    
    % Want to return negative log likelihood for minimizing. Also take care
    % of regularization in this step.
    
    theta(1) = 0; % Don't penalize mean.
    
    f    = -f + v/W * norm(theta)^2;
    grad = -grad + 2*v/W * theta;

end

function grad = numericalGrad(f,theta)
    delta_theta = 1e-4;
    grad = zeros(size(theta));
    for ii = 1:length(theta);
        thetaplus = theta; thetaplus(ii) = thetaplus(ii) + delta_theta;
        thetaminus = theta; thetaminus(ii) = thetaminus(ii) - delta_theta;
        grad(ii) = (f(thetaplus) - f(thetaminus)) / (2 * delta_theta);
    end
end