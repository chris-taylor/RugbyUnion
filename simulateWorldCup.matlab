function winner = simulateWorldCup(model,groups)

    assert(length(groups) == 4, 'Need 4 groups')

    [winnerA runnerupA] = simulateWorldCupGroup(model,groups{1});
    [winnerB runnerupB] = simulateWorldCupGroup(model,groups{2});
    [winnerC runnerupC] = simulateWorldCupGroup(model,groups{3});
    [winnerD runnerupD] = simulateWorldCupGroup(model,groups{4});
    
    winner = simulateKnockout(model,{winnerB, runnerupA, winnerC, runnerupD, winnerA, runnerupB, winnerD, runnerupC});

end