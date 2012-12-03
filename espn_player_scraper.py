import urllib2
import csv
import os

from bs4 import BeautifulSoup

# def run():
#     outfile = 'data/results.csv'
#     tmpfile = 'data/tmp.csv'

#     if os.path.isfile(tmpfile):
#         os.remove(tmpfile)
    
#     for country in get_country_names():
#         result = get_country_data(country)
#         if result is not None:
#             write_results(result,tmpfile)

#     remove_duplicate_lines(tmpfile,outfile)

def run():
    base = 'http://stats.espnscrum.com/scrumstats/rugby/stats/index.html?class=1;page='
    rest = ';template=results;type=player'

    outfile = 'data/espn.csv'

    if os.path.isfile(outfile):
        os.remove(outfile)

    with open(outfile,'w') as f:
        f.write('player,team,from,to,played,start,sub,pts,tries,conv,pens,drop,gfm,won,lost,draw\n')

    results = []

    for i in range(308):
        url = base + str(i+1) + rest
        print 'Loading', url
        write_results(scrape(url),outfile)

def scrape(url):
    bs = BeautifulSoup(urllib2.urlopen(url).read())
    rows = bs('table', {'class' : 'engineTable'})[1]('tr')[1:]
    results = []

    for row in rows:
        td = row('td')

        col = td[0].text
        player, team = col.split(' (')
        team = team[0:-1]

        dates = td[1].text
        dfrom, dto = dates.split('-')

        cols = [ safeint(cell.text) for cell in td[2:13] ]
        results.append( [player, team, dfrom, dto] + cols )

    return results

def safeint(str):
    try:
        return int(str)
    except:
        return 0


def write_results(results,outfile):
    try:
        f = open(outfile,'a')
    except:
        f = open(outfile,'w')

    w = csv.writer(f)

    for row in results:
        w.writerow(row)

    f.close()


# if __name__ == '__main__':
#     run()
