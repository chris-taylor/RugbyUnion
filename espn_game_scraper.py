import urllib2
import csv
import os
import sys
import mechanize
import datetime
import urlparse

from bs4 import BeautifulSoup

directory = 'data/'
outfile = directory + 'espn_internationals' + '.csv'
min_year = 1993
max_year = 2013

def set_trace():
    from IPython.core.debugger import Pdb
    Pdb(color_scheme='Linux').set_trace(sys._getframe().f_back)

def run():

    # Set up output directory
    if os.path.isfile(outfile):
        os.remove(outfile)

    with open(outfile,'w') as f:
        f.write('date,stadium,home_team,away_team,home_tries,home_penalties,home_conversions,home_drop_goals,away_tries,away_penalties,away_conversions,away_drop_goals\n')

    # Pages to visit
    base = 'http://www.espnscrum.com/scrum/rugby/series/index.html?season='
    years = []

    for (y1,y2) in zip(range(min_year, max_year), range(min_year+1, max_year+1)):
        years.append(str(y1))
        years.append(str(y1) + '%2F' + str(y2)[2:])

    # Visit each season's page
    ok = {'major tournament','major tour','major series',
          'minor tournament','minor tour','minor series'}
    notok = {'domestic tournament'}
    br = mechanize.Browser()
    for year in years:
        print '\nLoading year:', year.replace('%2F','-'), '\n'
        url = base + year
        response = br.open(url)
        soup = BeautifulSoup(response.get_data())
        make_links_absolute(soup,url)

        try:
            rows = soup.find_all('div',{'id':'scrumArticlesBoxContent'})[0].table.find_all('tr')
        except AttributeError:
            print "*** Failed to load year"
            continue

        read = False

        for row in rows:
            text = row.text.strip().lower()

            if text in ok:              # heading: international tour/tournament?
                read = True
                continue
            elif text in notok:         # heading: domestic tour/tournament?
                read = False
                continue
            else:                       # not a heading
                if 'Junior' in row.text or 'U20' in row.text:   # don't scrape U20 matches
                    continue
                if read:
                    links = [a['href'] for a in row.find_all('a') if a.text == 'Results']
                    if len(links) == 0:
                        continue
                    elif len(links) == 1:
                        print 'Loading tour:', row.td.text.strip().replace('\n',' ')
                        scrape(links[0])
                    else:
                        print '*** Multiple links?'
                        raise ValueError
    
    # print 'Scraping recent matches'
    # scrape('http://www.espnscrum.com/scrum/rugby/match/scores/recent.html')

    # print 'Scraping internationals'
    # scrape('http://www.espnscrum.com/scrum/rugby/match/scores/international.html')

def scrape(url):
    br = mechanize.Browser()
    br.open(url)

    assert br.viewing_html()

    match_links = [link for link in br.links()
                        if 'match' in link.url if '-' in link.text]

    for link in match_links:
        print '  Scraping:', link.text,
        response = br.open(link.url + '?view=scorecard')
        game = parse_game(response.get_data())
        if game is None:
            print '(no result)'
        else:
            print '(ok)'
            write_game(game, outfile)


def write_game(game,outfile):

    row = [game['date'], game['stadium'], game['home_team'], game['away_team']] + game['stats']

    with open(outfile,'a') as f:
        c = csv.writer(f)
        c.writerow(row)
        

def parse_game(html):

    bs = BeautifulSoup(html)

    # parse header
    header = bs('td',{'class':'liveSubNavText'})[0].text
    try:
        tour, rest = map(lambda x: x.strip(), header.split(' - '))
    except ValueError:
        return None

    try:
        stadium, date, local, gmt = [x.strip() for x in rest.split(',')]
    except ValueError:
        try:
            stadium, date = [x.strip() for x in rest.split(',')]
            local, gmt = None, None
        except:
            return None

    # parse scoreline
    # need to be smarter about doing this
    # example scorelines to be parsed:
    #    Portugal 31 - 32 England (FT)
    #    Russia 29 (13) - 43 (21) Romania (FT)
    #    ... and others?
    #
    scoreline = bs('td',{'class':'liveSubNavText1'})[0].text
    scoreline = scoreline.replace('(FT)','').strip()
    h, a = [s.strip() for s in scoreline.split(' - ')]

    h, hpts = h.rsplit(None,1)
    apts, a = a.split(None, 1)
    hpts, apts = int(hpts), int(apts)

    # parse content
    tabs = bs.find_all('div', {'class' : 'tabbertab'})

    tab_titles = [t.h2.text for t in tabs]

    team_idx = None
    match_stats_idx = None
    timeline_idx = None

    for i, t in enumerate(tab_titles):
        if t.lower() == 'teams':
            team_idx = i
        if t.lower() == 'match stats':
            match_stats_idx = i
        if t.lower() == 'timeline':
            timeline_idx = i

    if match_stats_idx is not None:

        # Parse game results
        rows = tabs[match_stats_idx].table('tr')

        row1 = rows[0]('td')
        home_team = row1[0].text
        away_team = row1[2].text

        for row in rows[1:]:
            
            try:
                d_home, title, d_away = [td.text for td in row.find_all('td')]
            except ValueError:
                continue

            title = title.lower()

            if 'tries' in title:
                home_tries = parse_tries(d_home)
                away_tries = parse_tries(d_away)

            elif 'conversion' in title:
                home_cons = int(d_home.split()[0])
                away_cons = int(d_away.split()[0])

            elif 'penalty goals' in title:
                home_pens = int(d_home.split()[0])  
                away_pens = int(d_away.split()[0])

            elif 'dropped goals' in title:
                home_drops = int(d_home.split()[0])
                away_drops = int(d_away.split()[0])

    elif team_idx is not None:

        rows = [row for row in tabs[team_idx].table('tr') if row.text.strip() != '']

        home_team, away_team = [t.text.strip() for t in rows[0]('td')]

        home_tries, away_tries, home_cons, away_cons, home_pens, away_pens, home_drops, away_drops = 0, 0, 0, 0, 0, 0, 0, 0

        for row in rows[1:]:
            
            if 'Team' in row.text:
                break
            
            d_home, d_away = [t.text for t in row.find_all('td')]

            if 'Tries' in row.text:
                home_tries = parse_number_of('Tries',d_home)
                away_tries = parse_number_of('Tries',d_away)
            elif 'Cons' in row.text:
                home_cons = parse_number_of('Cons',d_home)
                away_cons = parse_number_of('Cons',d_away)
            elif 'Pens' in row.text:
                home_pens = parse_number_of('Pens',d_home)
                away_pens = parse_number_of('Pens',d_away)
            elif 'Drops' in row.text:
                home_drops = parse_number_of('Drops',d_home)
                away_drops = parse_number_of('Drops',d_away)

    else:
        return None

    # check result against scoreline

    if 5 * home_tries + 3 * (home_pens + home_drops) + 2 * home_cons != hpts:
        print "(*** home scores don't match)",
        return None

    if 5 * away_tries + 3 * (away_pens + away_drops) + 2 * away_cons != apts:
        print "(*** away scores don't match)",
        return None

    # output

    game = {}
    game['tour'] = tour
    game['stadium'] = stadium
    game['local_time'] = local
    game['gmt_time'] = gmt
    game['home_team'] = home_team
    game['away_team'] = away_team
    game['date'] = datetime.datetime.strptime(date, '%d %B %Y').strftime('%Y-%m-%d')
    game['stats'] = [home_tries, home_pens, home_cons, home_drops, away_tries, away_pens, away_cons, away_drops]

    return game


def strip_parens(string):
    return string.lstrip('(').rstrip(')')


def parse_numbers(string):
    '''
    Given a player name, possibly followed by a number, this parses it, e.g.
        'Dixon 2'     => ('Dixon', 2)
        'Coles'       => ('Coles', 1)
        'El Said 4'   => ('El Said', 4) 
    '''
    tokens = string.rsplit(None, 1)
    if len(tokens) == 1:
        return tokens[0], 1
    elif tokens[1].isdigit():
        return tokens[0], int(tokens[1])
    else:
        return ' '.join(tokens), 1


def parse_number_of(thing,string):
    '''
    This function counts different kinds of goals, e.g. if called with thing='Tries' then it parses
        'Tries Dixon 2, Coles'      => 3
        'Tries Martin, Johnson'     => 2
        'Tries none'                => 0
        'Tries 3'                   => 3
    '''
    string = string.replace(thing,'').strip()
    if string == 'none':
        return 0
    elif string.isdigit():
        return int(string)
    else:
        counts = [parse_numbers(s.strip()) for s in string.split(',')]
        return sum(n for (player,n) in counts)


def parse_tries(string):
    if ' ' in string:   # might indicate a penalty try?
        tries, penalty = string.split(None,1)
        penalty = int(strip_parens(penalty).split()[0])
        tries = int(tries) + penalty
    else:               # just an int
        tries = int(string)
    return tries


def parse_dropped_goals(string):
    if ' ' in string:
        made, attempted = string.split(None,1)
        made = None
    else:
        made = int(string)

    return made


def make_links_absolute(soup, url):
    for tag in soup.findAll('a', href=True):
        tag['href'] = urlparse.urljoin(url, tag['href'])


# if __name__ == '__main__':
#     run()
