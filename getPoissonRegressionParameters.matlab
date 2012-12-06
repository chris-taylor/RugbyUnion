function [lambda_t_h lambda_p_h conv_h lambda_t_a lambda_p_a conv_a] = getPoissonRegressionParameters(model,home,away,opts)
% Get the rate parameters for a matchup between two teams in a given model.

    % Default arguments
    if nargin < 4
        opts = struct;
    end
    if ~isfield(opts,'homeadv')
        opts.homeadv = true;
    end
    if ~isfield(opts,'length')
        opts.length = 1;
    end

    if opts.homeadv
        lambda_t_h = opts.length * exp(model.tries.c + model.tries.g + model.tries.a(home) - model.tries.d(away));
        lambda_t_a = opts.length * exp(model.tries.c - model.tries.g + model.tries.a(away) - model.tries.d(home));
        lambda_p_h = opts.length * exp(model.pens.c + model.pens.g + model.pens.a(home) - model.pens.d(away));
        lambda_p_a = opts.length * exp(model.pens.c - model.pens.g + model.pens.a(away) - model.pens.d(home));
    else
        lambda_t_h = opts.length * exp(model.tries.c + model.tries.a(home) - model.tries.d(away));
        lambda_t_a = opts.length * exp(model.tries.c + model.tries.a(away) - model.tries.d(home));
        lambda_p_h = opts.length * exp(model.pens.c + model.pens.a(home) - model.pens.d(away));
        lambda_p_a = opts.length * exp(model.pens.c + model.pens.a(away) - model.pens.d(home));
    end
    
    conv_h = model.cons.p(home);
    conv_a = model.cons.p(away);

end