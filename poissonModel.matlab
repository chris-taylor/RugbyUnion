function model = poissonModel(data)

    XH = data.X;  XH(XH<0) = 0;
    XA = -data.X; XA(XA<0) = 0;
    
    n = length(data.countries);
    
    c     = 25;
    gamma = 0;
    a = zeros(n,1);
    d = zeros(n,1);
    
    theta0 = [c; gamma; a; d];
    
    f = @(theta) negativeLL(n,theta,XH,XA,data.homescore,data.awayscore);
    
    opts = optimset();
    opts.GradObj = 'on';
    opts.Display = 'iter';
    
    lb = -30 * ones(2*n+2,1);
    ub = +30 * ones(2*n+2,1);
    %lb = zeros(2*n+2,1);
    %ub = 30 * ones(2*n+2,1);
    
    [theta fval] = fmincon(f,theta0,[],[],[],[],lb,ub,[],opts);
    
    model.c     = theta(1);
    model.gamma = theta(2);
    model.a     = theta(3:n+2);
    model.d     = theta(n+3:2*n+2);
    model.countries = data.countries;
    model.predictHomeAdv   = @predictHomeAdv;
    model.predictNoHomeAdv = @predictNoHomeAdv;
    
    fprintf('Optimal fval: %.4f\n',fval)
    
    function p = predictHomeAdv(XH,XA)
        lambda = model.c + model.gamma + XH * model.a - XA * model.d;
        mu     = model.c - model.gamma + XA * model.a - XH * model.d;
        p      = predict(lambda,mu);
    end

    function p = predictNoHomeAdv(XH,XA)
        lambda = model.c + XH * model.a - XA * model.d;
        mu     = model.c + XA * model.a - XH * model.d;
        p      = predict(lambda,mu);
    end
    
    function p = predict(lambda,mu)
        
        [x y] = ndgrid(0:200);
        p     = zeros(length(lambda),3);
        
        ihomewin = x > y;
        idraw    = x == y;
        iawaywin = x < y;
        
        for ii = 1:length(lambda)
            homeps = stats.poissonpdf(0:200,lambda(ii));
            awayps = stats.poissonpdf(0:200,mu(ii));
            P = kron(homeps', awayps);
        
            p(ii,1) = sum(sum(P(ihomewin)));
            p(ii,2) = sum(sum(P(idraw)));
            p(ii,3) = sum(sum(P(iawaywin)));
        end
        
    end

end

function [f grad] = negativeLL(n,theta,XH,XA,x,y)

    T = length(x);
    v = 0.001;

    % Unpack params
    c     = theta(1);
    gamma = theta(2);
    a     = theta(3:n+2);
    d     = theta(n+3:2*n+2);
    
    lambda = c + XH * a - XA * d + gamma; % home team scoring rate
    mu     = c + XA * a - XH * d - gamma; % away team scoring rate
    
    % Value
    f = sum(-lambda - mu + x .* log(lambda) + y .* log(mu))/T;
    
    % Gradient
    dL_da = sum(-XH - XA + bsxfun(@times,XH,x./lambda) + bsxfun(@times,XA,y./mu))';
    dL_dd = sum( XA + XH - bsxfun(@times,XA,x./lambda) - bsxfun(@times,XH,y./mu))';
    dL_dc = sum(-2 + x ./ lambda + y ./ mu);
    dL_dg = sum(x ./ lambda - y ./ mu);
    
    grad = [dL_dc; dL_dg; dL_da; dL_dd]/T;
    
    % Want to return negative log likelihood for minimizing. Also take care
    % of regularization in this step.
    
    theta(1) = 0; % Don't penalize mean.
    
    f    = -f + v * norm(theta)^2;
    grad = -grad + v * theta;

end