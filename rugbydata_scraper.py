import urllib2
import csv
import os

from bs4 import BeautifulSoup

def run():
    outfile = 'data/results.csv'
    tmpfile = 'data/tmp.csv'

    if os.path.isfile(tmpfile):
        os.remove(tmpfile)
    
    for country in get_country_names():
        result = get_country_data(country)
        if result is not None:
            write_results(result,tmpfile)

    remove_duplicate_lines(tmpfile,outfile)


def get_country_data(country):

    baseurl  = 'http://rugbydata.com/'
    url = baseurl + country + '/gamesplayed/'
    bs  = BeautifulSoup(urllib2.urlopen(url).read())
    header = bs('table',{'class' : 'tablefontsize'})[1]('tr')[0]

    try:
        n = int(header.text.split('1 of ')[1])
    except:
        n = 1

    print country, ': %d pages to fetch' % n

    results = []

    for pagenum in range(n):
        thisurl = url + str(pagenum+1)
        print 'Loading %s' % thisurl

        bs = BeautifulSoup(urllib2.urlopen(thisurl).read())
        rows = bs('table',{'class' : 'tablefontsize'})[1]('tr')[1:]

        for row in rows:
            tds = row('td')

            date      = tds[1].text.encode('ascii')
            home_team = tds[2].text.encode('ascii')
            score     = tds[3].text.encode('ascii')
            away_team = tds[4].text.encode('ascii')

            score = score.split(' - ')
            home_score = score[0]
            away_score = score[1]

            results.append([date,home_team,home_score,away_score,away_team])

    return results


def get_country_names():
    f = open('data/countries.txt')
    countries = f.read().split('\n')
    return [c.replace(' ','').replace('&','and').lower() for c in countries]


def remove_duplicate_lines(fin,fout):
    with open(fin,'r') as infile:
        lines = list(set(infile.readlines()))
    with open(fout,'w') as outfile:
        outfile.writelines(lines)


def write_results(results,outfile):
    try:
        f = open(outfile,'a')
    except:
        f = open(outfile,'w')
        f.write('data,home_team,home_score,away_score,away_team\n')

    w = csv.writer(f)

    for row in results:
        w.writerow(row)

    f.close()


if __name__ == '__main__':
    run()
