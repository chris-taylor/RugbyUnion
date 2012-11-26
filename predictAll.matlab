function predictAll(model,games)

    for n = 1:length(games)
        p = predict(model,games{n}{1},games{n}{2});
        [pct idx] = max(p);
        if idx == 1
            fprintf('%12s to beat %-12s (%.1f%% certainty)\n',games{n}{1},games{n}{2},100*pct);
        elseif idx == 3
            fprintf('%12s to beat %-12s (%.1f%% certainty)\n',games{n}{2},games{n}{1},100*pct);
        end
    end

end