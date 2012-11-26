function x = binocombinations(n)
%Generate all binomial vectors of length n.
    if n == 1
        x = [0;1];
    else
        y = binocombinations(n-1);
        x = [repmat(0,size(y,1),1) y; repmat(1,size(y,1),1) y];
    end
end