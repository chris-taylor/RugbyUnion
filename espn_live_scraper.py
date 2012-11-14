import urllib2
import csv
import os
import mechanize
import datetime

from bs4 import BeautifulSoup

def run():
    
    print 'Scraping recent matches'
    scrape('http://www.espnscrum.com/scrum/rugby/match/scores/recent.html')

    print 'Scraping internationals'
    scrape('http://www.espnscrum.com/scrum/rugby/match/scores/international.html')

def scrape(url):
    br = mechanize.Browser()
    br.open(url)

    assert br.viewing_html()

    match_links = [link for link in br.links()
                        if 'match' in link.url if '-' in link.text]

    for link in match_links:
        print 'Scraping:', link.text
        response = br.open(link.url + '?view=scorecard')
        fname, timeline = parse_timeline(response.get_data())
        if timeline is not None:
            write_results(timeline, 'data/' + fname + '.csv')
        

def parse_timeline(html):

    bs = BeautifulSoup(html)

    # parse header
    header = bs('head')[0]('title')[0].text

    game, site, title = header.split(' - ')
    game, date, year = title.split(', ')
    teams, ground = game.split(' at ')
    home, away = teams.split(' v ')
    month, day = date.split(' ')

    date = date + ' ' + year
    date = datetime.datetime.strptime(date, '%b %d %Y').strftime('%Y%m%d')

    fname = date + '-' + home.replace(' ','') + '-' + away.replace(' ','')


    # parse content
    div = bs('div', {'id' : 'scrumContent'})[0]
    tabs = div('div', {'class' : 'tabbertab'})

    # try to find a 'Timeline' table
    table = None
    for tab in tabs:
        title = tab('h2')[0].text
        if 'Timeline' in title:
            table = tab('table')[0]
            break

    if table is None:
        return fname, None

    result = [['time','hometeam','homescore','awayscore','awayteam']]

    homescore, awayscore = 0, 0

    for row in table('tr')[1:]:

        time, home, score, away = [td.text for td in row('td')]

        try:
            time = int(time)
        except ValueError:
            # extra time is represented as u'40+2', so eval the string first
            time = int(eval(time))
        
        home = ';'.join(home.split('\n'))
        away = ';'.join(away.split('\n'))

        if score:
            # If there's a score string, split it to get each team's score
            score = score.split(' - ')
            homescore, awayscore = map(int, score)

        result.append([time, home, homescore, awayscore, away])

    return fname, result



def parse_header(row):
    hdrs = [cell.text for cell in row('td')]
    home = hdrs[1][0:-1]
    away = hdrs[3][1:]
    return ['Time', home, 'Home', 'Away', away]





def write_results(results,outfile):

    if os.path.isfile(outfile):
        return
    else:
        with open(outfile,'w') as f:
            writer = csv.writer(f)
            for row in results:
                writer.writerow(row)


# if __name__ == '__main__':
#     run()
