function modelSummary(model)

    X = [0 length(model.tries.a)+1];

    subplot(3,2,1)
    bar(model.tries.a);
    title('Tries (attack)')
    xlim(X)
    grid on
    
    subplot(3,2,2)
    bar(model.tries.d);
    title('Tries (defence)')
    xlim(X)
    grid on
    
    subplot(3,2,3)
    bar(model.pens.a);
    title('Penalties (attack)')
    xlim(X)
    grid on
    
    subplot(3,2,4)
    bar(model.pens.d);
    title('Penalties (defense)')
    xlim(X)
    grid on
    
    subplot(3,2,5)
    bar(model.cons.p);
    title('Conversions')
    xlim(X)
    grid on
    
    fprintf('    Tries average:  %.2f\n',model.tries.c)
    fprintf('    Tries home adv: %.2f\n',model.tries.g)
    fprintf('Penalties average:  %.2f\n',model.pens.c)
    fprintf('Penalties home adv: %.2f\n',model.pens.g)
    
end