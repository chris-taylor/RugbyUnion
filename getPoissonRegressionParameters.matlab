function [lambda_t_h lambda_p_h conv_h lambda_t_a lambda_p_a conv_a] = getPoissonRegressionParameters(model,home,away,adv,len)
% Get the rate parameters for a matchup between two teams in a given model.

    % Default arguments
    if nargin < 5
        len = 1;
    end

    lambda_t_h = len * exp(model.tries.c + model.tries.g .* adv + model.tries.a(home) - model.tries.d(away));
    lambda_t_a = len * exp(model.tries.c - model.tries.g .* adv + model.tries.a(away) - model.tries.d(home));
    lambda_p_h = len * exp(model.pens.c + model.pens.g .* adv + model.pens.a(home) - model.pens.d(away));
    lambda_p_a = len * exp(model.pens.c - model.pens.g .* adv + model.pens.a(away) - model.pens.d(home));

    conv_h = model.cons.p(home);
    conv_a = model.cons.p(away);

end