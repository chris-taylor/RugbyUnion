function quickStats(data)

    columns = {'Mean','Median','Min','Max','StDev'};
    rows = {'Home tries','Home penalties','Home drops','Home conversions',...
            'Away tries','Away penalties','Away drops','Away conversions'};

        
    X = [data.hometries, data.homepens, data.homedrops, data.homecons, ...
         data.awaytries, data.awaypens, data.awaydrops, data.awaycons]';
     
     fmt = {'%4.2f','%d','%d','%d','%4.2f'};
     
    util.printTable([mean(X,2), median(X,2), min(X,[],2), max(X,[],2), std(X,[],2)],columns,rows,fmt,18)

    fprintf('\n')
    fprintf('Home conversion rate: %.1f%%\n',100*sum(data.homecons)/sum(data.hometries))
    fprintf('Away conversion rate: %.1f%%\n',100*sum(data.awaycons)/sum(data.awaytries))

end