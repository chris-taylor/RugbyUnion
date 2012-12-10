function output = simulateWorldCupGroup(model,teams,ihost)

    N = length(teams);
    
    matchpoints = zeros(N,N);
    ptsfor = zeros(N,N);
    triesfor = zeros(N,N);
    
    for n = 1:N
        for m = 1:N
            
            if n == m
                continue
            end
            
            if n == ihost
                opts.homeadv = 1;
            elseif m == ihost
                opts.homeadv = -1;
            else
                opts.homeadv = 0;
            end
            
            [junk hpts apts htries atries] = simulateGame(model,teams(n),teams(m),opts);
            
            ptsfor(n,m) = hpts;
            ptsfor(m,n) = apts;
            
            triesfor(n,m) = htries;
            triesfor(m,n) = atries;
            
            if hpts > apts
                matchpoints(n,m) = 4;
                if hpts - apts <= 7 % bonus point
                    matchpoints(m,n) = 1;
                end
            elseif hpts == apts
                matchpoints(n,m) = 2;
                matchpoints(m,n) = 2;
            elseif hpts < apts
                matchpoints(m,n) = 4;
                if apts - hpts <= 7 % bonus point
                    matchpoints(n,m) = 1;
                end
            end
            
            if htries >= 4
                matchpoints(n,m) = matchpoints(n,m) + 1;
            end
            
            if atries >= 4
                matchpoints(m,n) = matchpoints(m,n) + 1;
            end
            
        end
    end
    
    matchpoints = sum(matchpoints,2);
    ptsdifference = sum(ptsfor,2) - sum(ptsfor,1)';
    triesdifference = sum(triesfor,2) - sum(triesfor,1)';
    totalgamepoints = sum(ptsfor,2);
    totaltries = sum(triesfor,2);
    
    for n = 1:N
        result(n).team = teams(n);
        result(n).idx = n;
        result(n).matchpoints = matchpoints(n);
        result(n).ptsfor = ptsfor(n,:);
        result(n).ptsdifference = ptsdifference(n);
        result(n).triesdifference = triesdifference(n);
        result(n).totalpoints = totalgamepoints(n);
        result(n).totaltries = totaltries(n);
    end
   
    
    % Determine the winner
    
    sorted = bubblesort(result);
    
    output.winner = sorted(1).team;
    output.runnerup = sorted(2).team;
    
    output.teams = teams([sorted.idx]);
    output.matchpoints = [sorted.matchpoints];
    output.ptsfor = [sorted.totalpoints];
    output.ptsdifference = [sorted.ptsdifference];
    output.triesfor = [sorted.totaltries];
    output.triesdifference = [sorted.triesdifference];
    
end

function str = bubblesort(str)

    N = length(str);
    
    for n = 1:N
        for m = 1:N-n
            a = str(m);
            b = str(m+1);
            c = compare(a,b);
            if c
                str(m) = b;
                str(m+1) = a;
            end
        end
    end

end

function c = compare(a,b)
    if a.matchpoints < b.matchpoints
        c = 1; return
    elseif a.matchpoints > b.matchpoints
        c = 0; return
    end
    if a.ptsfor(b.idx) < b.ptsfor(a.idx)
        c = 1; return
    elseif a.ptsfor(b.idx) > b.ptsfor(a.idx)
        c = 0; return
    end
    if a.ptsdifference < b.ptsdifference
        c = 1; return
    elseif a.ptsdifference > b.ptsdifference
        c = 0; return
    end
    if a.triesdifference < b.triesdifference
        c = 1; return
    end
    if a.totalpoints < b.totalpoints
        c = 1; return
    elseif a.totalpoints > b.totalpoints
        c = 0; return
    end
    if a.totaltries < b.totaltries
        c = 1; return
    elseif a.totaltries > b.totaltries
        c = 0; return
    else
        c = 0;
    end
end