import urllib2
import csv
import os
import mechanize

from bs4 import BeautifulSoup

def run():
    br = mechanize.Browser()
    br.open('http://www.espnscrum.com/scrum/rugby/match/scores/recent.html')

    assert br.viewing_html()

    match_links = [link for link in br.links()
                        if 'match' in link.url if '-' in link.text]

    for link in match_links:
        print 'Scraping:', link.text
        response = br.open(link.url + '?view=scorecard')
        timeline = parse_timeline(response.get_data())
        write_results(timeline, 'data/' + link.text + '.csv')
        

def parse_timeline(html):

    bs = BeautifulSoup(html)

    try:
        # Try to unpack a row of the first table you see, check it has
        # four elements.
        rows = bs('table')[3]('tr')
        a, b, c, d = rows[1]('td')
    except ValueError:
        # There's probably a commentary box, so get the next table and hope
        # that works...
        rows = bs('table')[4]('tr')


    result = [parse_header(rows[0])]

    for row in rows[1:]:

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
            homescore = int(score[0])
            awayscore = int(score[1])
        else:
            # Otherwise it's the start of the match, so it's 0 - 0
            homescore = 0
            awayscore = 0

        result.append([time, home, homescore, awayscore, away])

    return result



def parse_header(row):
    hdrs = [cell.text for cell in row('td')]
    home = hdrs[1][0:-1]
    away = hdrs[3][1:]
    return ['Time', home, 'Home', 'Away', away]





def write_results(results,outfile):

    with open(outfile,'w') as f:

        w = csv.writer(f)

        for row in results:
            w.writerow(row)


# if __name__ == '__main__':
#     run()
