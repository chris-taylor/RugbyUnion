function res = choose(n,k)

    res = exp(gammaln(n+1) - gammaln(k+1) - gammaln(n-k+1));

end