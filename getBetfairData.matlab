function event = getBetfairData()
%Read in .csv files from betfair.
%Format is
%"SPORTS_ID","EVENT_ID","SETTLED_DATE","FULL_DESCRIPTION","SCHEDULED_OFF","
%"EVENT","DT ACTUAL_OFF","SELECTION_ID","SELECTION","ODDS","NUMBER_BETS",
%"VOLUME_MATCHED","LATEST_TAKEN","FIRST_TAKEN","WIN_FLAG","IN_PLAY"

    fileName = 'bfinf_other_121119to121125_121128131846.csv';
    pathToFile = fullfile('data','betfair',fileName);
    fileId = fopen(pathToFile);
    
%     n = 0;
%     while 1
%         tline = fgetl(fid);
%         if n > 10
%             break
%         end
%         n = n + 1;
%         disp(tline)
%     end
    
    fmt = '"%d" "%d" %q %q %q %q %q "%d" %q "%f" "%f" "%f" %q %q %q %q';
    csv=textscan(fileId,fmt,'headerlines',1,'delimiter',',');
    fclose(fileId);
    
    % Interested in events such that:
    %   SPORTS_ID == 5 (Rugby Union)
    %   Only most recent odds
    %   Sufficiently liquid
    %   Only some bets (match odds/total match points/etc... liquidity
    %   filter?)
    
    % Rugby has SPORTS_ID == 5
    idx1 = csv{1} == 5;
    
    % Match odds only?
    idx2 = cellfun(@(str)strcmp(str,'Match Odds'), csv{6});
    
    % Overall id
    idx = idx1 & idx2;
    
    
    
    data.sports_id = csv{1}(idx);
    data.event_id = csv{2}(idx);
    data.settled_date = datenum(csv{3}(idx),'dd-mm-yyyy HH:MM:SS');
    data.full_description = csv{4}(idx);
    data.scheduled_off = datenum(csv{5}(idx),'dd-mm-yyyy HH:MM');
    data.event = csv{6}(idx);
%     data.actual_off = datenum(csv{7}(idx),'dd-mm-yyyy HH:MM'); % investigate parse fail?
%   looks like parse fails because some fields are empty - does this
%   signify an event that never started? put in check for empty strs?
    data.selection_id = csv{8}(idx);
    data.selection = csv{9}(idx);
    data.odds = csv{10}(idx);
    data.number_bets = csv{11}(idx);
    data.volume_matched = csv{12}(idx);
    data.latest_taken = datenum(csv{13}(idx),'dd-mm-yyyy HH:MM:SS');
    data.first_taken = datenum(csv{14}(idx),'dd-mm-yyyy HH:MM:SS');
    data.win_flag = cellfun(@str2num,csv{15}(idx));
    data.in_play = csv{16}(idx);
    
    % Save data?
    
    tmp = string.split(fileName,'_');
    tmp = string.split(tmp{3},'to');
    sdate = datestr(datenum(tmp{1},'yymmdd'),'YYYYmmdd');
    edate = datestr(datenum(tmp{2},'yymmdd'),'YYYYmmdd');
    outFile = sprintf('betfair-%s-%s.mat',sdate,edate);
    save(fullfile('data','betfair',outFile),'data');
    
    % Split out event ids
    
    unique_ids = unique(data.event_id);
        
    countries = loadCountries();
    event = struct;
    
    for ii = 1:length(unique_ids)
       
        % Unique event id
        id = unique_ids(ii);
        event_idx = find(data.event_id == id);

        % Get home/away teams and domestic vs international
        description = data.full_description{event_idx(1)};
        desc_parts = string.split(description,'/');
        teams = string.split(desc_parts{end},' v ');
        home = strtrim(teams{1});
        away = strtrim(teams{2});
        isInternational = ismember(home,countries) || ismember(away,countries);
        
        event(ii).id = id;
        event(ii).full_description = data.full_description{event_idx(1)};
        event(ii).settled_date = data.settled_date(event_idx(1));
        event(ii).scheduled_off = data.scheduled_off(event_idx(1));
        event(ii).event = data.event{event_idx(1)};
        event(ii).home = home;
        event(ii).away = away;
        event(ii).international = isInternational;
        
        unique_selection_ids = unique(data.selection_id(event_idx));
        
        for jj = 1:length(unique_selection_ids)
            
            % Pick out rows corresponding to this market
            selection_id = unique_selection_ids(jj);
            selection_idx = find(data.selection_id == selection_id);
            
            odds = data.odds(selection_idx);
            number_bets = data.number_bets(selection_idx);
            volume_matched = data.volume_matched(selection_idx);
            latest_taken = data.latest_taken(selection_idx);
            first_taken = data.first_taken(selection_idx);
            
            % Only look at odds the day before the event
            time_idx = latest_taken > event(ii).scheduled_off - 1 & latest_taken < event(ii).scheduled_off;
            
            odds = odds(time_idx);
            number_bets = number_bets(time_idx);
            volume_matched = volume_matched(time_idx);
            latest_taken = latest_taken(time_idx);
            first_taken = first_taken(time_idx);
            
            % Mean odds
            meanOdds = sum(odds .* volume_matched) / sum(volume_matched);
            
            % Event stats
            event(ii).selection(jj).name = data.selection{selection_idx(1)};
            event(ii).selection(jj).win_flag = data.win_flag(selection_idx(1));
            event(ii).selection(jj).mid = meanOdds;
            event(ii).selection(jj).volume = max(volume_matched);
            event(ii).selection(jj).total_matched = sum(volume_matched);
            event(ii).selection(jj).odds = odds;
            event(ii).selection(jj).number_bets = number_bets;
            event(ii).selection(jj).volume_matched = volume_matched;
            event(ii).selection(jj).latest_taken = latest_taken;
            event(ii).selection(jj).first_taken = first_taken;
        end
        
        % Ensure that there is an overround of 2%
        prob = 1./ [event(ii).selection.mid];
        prob = prob / sum(prob);
        
        for jj = 1:length(unique_selection_ids)
            event(ii).selection(jj).back = 1/prob(jj) - 0.5 * tickSize(1/prob(jj));
            event(ii).selection(jj).lay = 1/prob(jj) + 0.5 * tickSize(1/prob(jj));
        end
        
    end
        
    
    % Pick out match odds and internationals?
    
%     loc = cellfun(@(str)strcmp(str,'Match Odds'), {event.event});
%     event = event(loc);

    loc = [event.international] == 1;
    event = event(loc);
    
    

end