function model = poissonModel(data,t_half,v,t)

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
    
    % Create model
    triesModel       = fitPoisson(data.hometries, data.awaytries, XH, XA, wts, v);
    penaltiesModel   = fitPoisson(data.homepens + data.homedrops, data.awaypens + data.awaydrops, XH, XA, wts, v);
    conversionsModel = fitConversions(data.hometries, data.homecons, data.awaytries, data.awaycons, XH, XA);
    
    model.tries = triesModel;
    model.pens = penaltiesModel;
    model.cons = conversionsModel;
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
    
        [th ph ch ta pa ca] = getRateParameters(model,iHome,iAway,opts);
        
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

function model = fitConversions(ht,hc,at,ac,XH,XA)

    ntries = XH' * ht + XA' * at;
    ncons  = XH' * hc + XA' * ac;
    
    model.p = ncons ./ ntries;

end

function model = fitPoisson(x,y,XH,XA,w,v)

%     debug = false;

    n = size(XH,2);
    
    c = mean([x;y]);
    g = mean((x-y)/2);
    a = zeros(n,1);
    d = zeros(n,1);
    
    theta0 = [c; g; a; d];
    
    f = @(theta) negativeLL(n,theta,XH,XA,x,y,w,v);
    opts = optimset();
    opts.GradObj = 'on';
    opts.Display = 'iter';
    
%     if debug
%         [fval grad1] = negativeLL(n,theta0,XH,XA,x,y,w,v);
%         grad2 = numericalGrad(f, theta0);
%         figure; bar(grad1 - grad2)
%         keyboard
%     end
    
    theta = fminunc(f,theta0,opts);

%     Aeq = [0 0 ones(1,n) zeros(1,n)];
%     beq = 0;
%     theta = fmincon(f,theta0,[],[],Aeq,beq,[],[],[],opts);
    
    model.c = theta(1);
    model.g = theta(2);
    model.a = theta(3:n+2);
    model.d = theta(n+3:2*n+2);

end

function [f grad] = negativeLL(n,theta,XH,XA,x,y,w,v)

    % Unpack params
    c = theta(1);           % mean scoring rate
    g = theta(2);           % home advantage
    a = theta(3:n+2);       % attacking team
    d = theta(n+3:2*n+2);   % defending team
    
    W = sum(w);             % sum of weights
    
    % IDEA:
    % Since lambda, mu are poisson parameters, should use the poisson
    % conjugate prior (ie gamma distn) to regularize. This means we'd have
    % a term like
    %   V(lambda) = (lambda - c * log(lambda)) * g
    % where lambda is the poisson rate param, c is the avg. occurences per
    % time unit, and g is the number of time units in the
    % pseudo-observations. This gives an infinite penalty to values of
    % lambda/mu that are negative, which solves the negative rate problem?
    
    % ANOTHER IDEA:
    % Instead of lambda = c + g + a - d
    % Use lambda = exp(c + g + a - d)
    % This means that lambda can never be negative, and the only change is
    % that when computing the gradient you have e.g.
    %   d lambda / d c = exp(c + g + a - d) = lambda
    % instead of
    %   d lambda / d c = 1.
    % The interpretation of the parameters is a little less clear, but I
    % think it may be worth it.
    % Can then regularize using norm(theta) instead of idea above.
    
    % THIRD IDEA
    % Instead of passing in XH, XA etc should I use a vector of indexes
    % iHome, iAway and use those to index into a/d?
    % Will mean multiplication is much faster, so should be quicker to fit
    % models. Might make the gradient code a little tricker? But maybe
    % not...
    
    lambda = c + XH * a - XA * d + g; % home team scoring rate
    mu     = c + XA * a - XH * d - g; % away team scoring rate
    
    % Value
    f = sum(w .* (-lambda - mu + x .* log(lambda) + y .* log(mu))) / W;
    
    % Gradient
    dL_da = sum(bsxfun(@times, w, (-XH - XA + bsxfun(@times,XH,x./lambda) + bsxfun(@times,XA,y./mu))))';
    dL_dd = sum(bsxfun(@times, w, ( XA + XH - bsxfun(@times,XA,x./lambda) - bsxfun(@times,XH,y./mu))))';
    dL_dc = sum(w .* (-2 + x ./ lambda + y ./ mu));
    dL_dg = sum(w .* (x ./ lambda - y ./ mu));
    
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