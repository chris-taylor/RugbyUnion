function score = multinomialBrierScore(prediction,actual)

    score = mean(sum((prediction - actual).^2, 2));

end