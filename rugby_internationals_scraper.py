import urllib2
import csv
import os
import sys
import datetime

from bs4 import BeautifulSoup

def set_trace():
    from IPython.core.debugger import Pdb
    Pdb(color_scheme='Linux').set_trace(sys._getframe().f_back)

def run():
    years = [2007, 2008, 2009, 2010, 2011, 2012]

    base = 'http://www.rugbyinternational.net/fixtures-results/'
    rest = '-fixtures-results.htm'

    fname = 'data/internationals.csv'

    if os.path.isfile(fname):
        os.remove(fname)

    with open(fname,'w') as f:
        f.write('date,home_team,away_team,home_tries,home_penalties,home_conversions,home_drop_goals,away_tries,away_penalties,away_conversions,away_drop_goals\n')

    for year in years:
        url = base + str(year) + rest

        print 'Reading:', url

        soup = BeautifulSoup(urllib2.urlopen(url).read())
        urls = unique(a.get('href') for a in soup.find_all('a') if a.has_key('href'))
        urls = [url for url in urls if 'data' in url or 'espn' in url or 'bbc' in url]

        for url in urls:
            if url.endswith('.xls'):
                url = url.replace('xls','htm')

            result = scrape(url)
            
            if result:
                write_result(result,fname)

    print 'Done!'

def unique(lst):
    return list(set(lst))

def write_result(game,fname):

    def get_line(s):
        def total(xs):
            return sum([n for (player,n) in xs])
        return map(total,[s['tries'], s['penalties'], s['conversions'], s['dropgoals']])

    home = game['home']
    away = game['away']

    row = [game['date'], home['team'], away['team']] + get_line(home['score']) + get_line(away['score'])

    with open(fname,'a') as f:
        c = csv.writer(f)
        c.writerow(row)

def scrape(url):

    print '  Scraping:', url

    if 'rugbyinternational.net/data' in url:
        game = scrape_ri(url)
    elif 'espnscrum' in url:
        game = scrape_espn(url)
    elif 'bbc.co.uk' in url:
        game = scrape_bbc(url)
    else:
        raise ValueError

    return game

def scrape_espn(url):
    return None

def scrape_bbc(url):
    return None

def scrape_ri(url):

    def parse_row(row):
        scores = [td.text for td in row.find_all('td') if td.text.strip() != '']
        
        if len(scores) == 2:
            nhome = parse_line(scores[0])
            naway = parse_line(scores[1])
        else:
            strhome = row('td')[2].text.strip()     
            straway = row('td')[5].text.strip()
            nhome, naway = parse_line(strhome), parse_line(straway)

        return nhome, naway

    def parse_line(line):
        if line == '':
            return []
        ps = [p for p in line.split(':',1)[1].split(',') if p.strip() != '']
        return [parse_player(p.strip()) for p in ps]
        
    def parse_player(p):
        if p.startswith('('):
            player, num = '', int(strip_parens(p))
        elif p.endswith(')'):
            player, num = p.replace('(',' (').rsplit(None, 1)
            num = int(strip_parens(num))
        else:
            player, num = p, 1
        return player, num

    def get_teams(row):
        try:
            team1, score1 = row.find_all('td')[2].text.encode('ascii','ignore').rsplit(None,1)
            team1 = team1.replace('\n','').replace('\r','').title()
        except:
            raise ValueError('Failed to parse team name')

        try:
            team2, score2 = row.find_all('td')[5].text.encode('ascii','ignore').rsplit(None,1)
        except: # sometimes the second team appears in column 4...
            team2, score2 = row.find_all('td')[4].text.encode('ascii','ignore').rsplit(None,1)
        
        team2 = team2.replace('\n','').replace('\r','').title()
        
        try:
            score1 = int(score1)
        except:
            team1 = team1 + ' ' + score1
            score1 = 0

        try:
            score2 = int(score2)
        except:
            team2 = team2 + ' ' + score2
            score2 = 0

        return team1, int(score1), team2, int(score2)

    try:
        date = url.rsplit('/',1)[1][0:8]
        date = datetime.datetime.strptime(date, '%Y%m%d').strftime('%Y-%m-%d')
    except:
        print '  *** Date parse error'
        return None

    try:
        html = urllib2.urlopen(url).read()
    except urllib2.HTTPError:
        print '  *** 404 error'
        return None
    except urllib2.UrlError:
        print '  *** Request timed out'
        return None

    try:
        soup = BeautifulSoup(html)
        rows = soup.table.find_all('tr')
    except:
        print '  * Error reading html'
        return None

    # Get team names and total score

    try:
        team1, score1, team2, score2 = get_teams(soup.table.tr)
    except ValueError:
        print '  ** Team name parsing error'
        return None

    # Get scores

    hometries, awaytries = parse_row([r for r in rows if 'TRIES' in r.text][0])
    homeconvs, awayconvs = parse_row([r for r in rows if 'CONVERSIONS' in r.text][0])
    homepens, awaypens = parse_row([r for r in rows if 'PENALTY' in r.text][0])
    homedrops, awaydrops = parse_row([r for r in rows if 'DROPPED' in r.text][0])

    # TODO: check that number of points matches up!

    home = {'tries':hometries, 'conversions':homeconvs, 'penalties':homepens, 'dropgoals':homedrops}
    away = {'tries':awaytries, 'conversions':awayconvs, 'penalties':awaypens, 'dropgoals':awaydrops}

    return {'date':date, 'home':{'team':team1, 'score':home}, 'away':{'team':team2, 'score':away}}

def strip_parens(string):
    return string.lstrip('(').rstrip(')')
    