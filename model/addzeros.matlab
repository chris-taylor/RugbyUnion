function x = addzeros(x)

    x = [repmat(0, size(x,1), 1) x];

end