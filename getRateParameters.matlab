function [lambda_t_h lambda_p_h conv_h lambda_t_a lambda_p_a conv_a] = getRateParameters(model,home,away,opts)
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

    % Simulate the game
    ihome = strmatch(home,model.teams,'exact');
    iaway = strmatch(away,model.teams,'exact');
    
    if opts.homeadv
        lambda_t_h = opts.length * (model.tries.c + model.tries.g + model.tries.a(ihome) - model.tries.d(iaway));
        lambda_t_a = opts.length * (model.tries.c - model.tries.g + model.tries.a(iaway) - model.tries.d(ihome));
        lambda_p_h = opts.length * (model.pens.c + model.pens.g + model.pens.a(ihome) - model.pens.d(iaway));
        lambda_p_a = opts.length * (model.pens.c - model.pens.g + model.pens.a(iaway) - model.pens.d(ihome));
    else
        lambda_t_h = opts.length * (model.tries.c + model.tries.a(ihome) - model.tries.d(iaway));
        lambda_t_a = opts.length * (model.tries.c + model.tries.a(iaway) - model.tries.d(ihome));
        lambda_p_h = opts.length * (model.pens.c + model.pens.a(ihome) - model.pens.d(iaway));
        lambda_p_a = opts.length * (model.pens.c + model.pens.a(iaway) - model.pens.d(ihome));
    end

    conv_h = model.cons.p(ihome);
    conv_a = model.cons.p(iaway);

end