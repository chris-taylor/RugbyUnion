function model = poissonModel(data)

    XH = data.X;  XH(XH<0) = 0;
    XA = -data.X; XA(XA<0) = 0;
    
    triesModel       = fitPoisson(data.hometries, data.awaytries, XH, XA);
    penaltiesModel   = fitPoisson(data.homepens + data.homedrops, data.awaypens + data.awaydrops, XH, XA);
    conversionsModel = fitConversions(data.hometries, data.homecons, data.awaytries, data.awaycons, XH, XA);
    
    model.tries = triesModel;
    model.pens = penaltiesModel;
    model.cons = conversionsModel;
    model.teams = data.teams;
    model.predictHomeAdv   = @predictHomeAdv;
    model.predictNoHomeAdv = @predictNoHomeAdv;
    
    function p = predictHomeAdv(XH,XA)
        lambda_t_h = model.tries.c + model.tries.g + XH * model.tries.a - XA * model.tries.d;
        lambda_t_a = model.tries.c - model.tries.g + XA * model.tries.a - XH * model.tries.d;
        
        lambda_p_h = model.pens.c + model.pens.g + XH * model.pens.a - XA * model.pens.d;
        lambda_p_a = model.pens.c - model.pens.g + XA * model.pens.a - XH * model.pens.d;
        
        conv_h = XH * model.cons.p;
        conv_a = XA * model.cons.p;
        
        p = predict(lambda_t_h,lambda_p_h,conv_h,lambda_t_a,lambda_p_a,conv_a);
    end

    function p = predictNoHomeAdv(XH,XA)
        lambda_t_h = model.tries.c + XH * model.tries.a - XA * model.tries.d;
        lambda_t_a = model.tries.c + XA * model.tries.a - XH * model.tries.d;
        
        lambda_p_h = model.pens.c + XH * model.pens.a - XA * model.pens.d;
        lambda_p_a = model.pens.c + XA * model.pens.a - XH * model.pens.d;
        
        conv_h = XH * model.cons.p;
        conv_a = XA * model.cons.p;
        
        p = predict(lambda_t_h,lambda_p_h,conv_h,lambda_t_a,lambda_p_a,conv_a);
    end
    
    function p = predict(th,ph,ch,ta,pa,ca)
        
        n = length(th);
        [x y] = ndgrid(0:150);
        p     = zeros(n,3);
        
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
        
    end

end

function model = fitConversions(ht,hc,at,ac,XH,XA)

    ntries = XH' * ht + XA' * at;
    ncons  = XH' * hc + XA' * ac;
    
    model.p = ncons ./ ntries;

end

function model = fitPoisson(x,y,XH,XA)

    n = size(XH,2);
    
    c = 1;
    g = 0;
    a = zeros(n,1);
    d = zeros(n,1);
    
    theta0 = [c; g; a; d];
    
    f = @(theta) negativeLL(n,theta,XH,XA,x,y);
    opts = optimset();
    opts.GradObj = 'on';
    opts.Display = 'iter';
    
    theta = fminunc(f,theta0,opts);
    
    model.c = theta(1);
    model.g = theta(2);
    model.a = theta(3:n+2);
    model.d = theta(n+3:2*n+2);

end

function [f grad] = negativeLL(n,theta,XH,XA,x,y)

    T = length(x);
    v = 0.001;

    % Unpack params
    c = theta(1);           % mean scoring rate
    g = theta(2);           % home advantage
    a = theta(3:n+2);       % attacking team
    d = theta(n+3:2*n+2);   % defending team
    
    lambda = c + XH * a - XA * d + g; % home team scoring rate
    mu     = c + XA * a - XH * d - g; % away team scoring rate
    
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