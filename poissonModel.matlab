function model = poissonModel(data)

    XH = data.X;  XH(XH<0) = 0;
    XA = -data.X; XA(XA<0) = 0;
    
    n = length(data.countries);
    
    c     = 25;
    gamma = 0;
    a = zeros(n,1);
    d = zeros(n,1);
    
    theta0 = [c; gamma; a; d];
    
    f = @(theta) modelLL(n,theta,XH,XA,data.homescore,data.awayscore);
    
    opts = optimset();
    opts.GradObj = 'on';
    
    lb = -30 * ones(2*n+2,1);
    ub = +30 * ones(2*n+2,1);
    
    theta = fmincon(f,theta0,[],[],[],[],lb,ub,[],opts);
    
    model.c     = theta(1);
    model.gamma = theta(2);
    model.a     = theta(3:n+2);
    model.d     = theta(n+3:2*n+2);
    model.countries = data.countries;
    model.predict = @predict;
    
    function p = predict(home,away)
       
        ihome = strmatch(home,model.countries,'exact');
        iaway = strmatch(away,model.countries,'exact');
        
        lambda = model.c + model.gamma + model.a(ihome) - model.d(iaway);
        mu     = model.c - model.gamma + model.a(iaway) - model.d(ihome);
        
        homeps = stats.poissonpdf(0:200,lambda);
        awayps = stats.poissonpdf(0:200,mu);
        
        P = kron(homeps', awayps);
        
        [x y] = ndgrid(0:200);
        
        p(1) = sum(sum(P(x>y)));
        p(2) = sum(sum(P(x==y)));
        p(3) = sum(sum(P(x<y)));
        
    end

end

function [f grad] = modelLL(n,theta,XH,XA,x,y)

    T = length(x);

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
    
    f = -f;
    grad = -grad;

end