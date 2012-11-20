function p = poissonpdf(k,lambda)

    p = exp(-lambda + k * log(lambda) - gammaln(k+1));

end