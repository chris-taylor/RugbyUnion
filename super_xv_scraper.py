import mechanize
import csv
import os
import sys
import datetime

import bs4

def set_trace():
    from IPython.core.debugger import Pdb
    Pdb(color_scheme='Linux').set_trace(sys._getframe().f_back)

def run():
    base = 'http://www.superxv.com/results/'
    directory = 'data/'
    br = mechanize.Browser()
    br.open(base)

    urls = [link.absolute_url for link in br.links() if 'HERE' in link.text]
    fname = directory + 'superxv.csv'

    if os.path.isfile(fname):
        os.remove(fname)

    with open(fname,'w') as f:
        f.write('date,home_team,away_team,home_tries,home_penalties,home_conversions,home_drop_goals,away_tries,away_penalties,away_conversions,away_drop_goals\n')

    for url in urls:
        print 'Starting season:', url
        br.open(url)
        games = [link.absolute_url for link in br.links() if 'match report' in link.text.lower()]
        for game in games:
            print ' Reading game:', game
            html = br.open(game).get_data()

            try:
                game = parse_game(html)
            except:
                print ' *** parse error'
                continue

            if game:
                write_game(game,fname)
            else:
                print ' *** parse fail'

    print 'Done!'


def write_game(game,fname):

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


def parse_game(html):

    from collections import defaultdict

    bs = bs4.BeautifulSoup(html)

    # pull the date from the page and format it
    date = bs('span', {'style':'bold'})[0].text
    date = datetime.datetime.strptime(date, '%A %d %B %Y').strftime('%Y-%m-%d')

    # try to parse the article
    i, started = -1, False
    scores = [defaultdict(lambda: ''), defaultdict(lambda: '')]

    for string in bs.article.stripped_strings:

        if started:

            # if is_terminal(string):
            #     break

            if contains_team_name(string):
                i += 1
                if i > 1:
                    break
                key = 'team'
            elif is_try(string):
                key = 'tries'
            elif is_pen(string):
                key = 'penalties'
            elif is_con(string):
                key = 'conversions'
            elif is_drop(string):
                key = 'dropgoals'
            elif is_card(string):
                key = 'cards'

            scores[i][key] += string

        if len(string) < 15 and ('scorers' in string.lower() or 'scoring' in string.lower()):
            started = True

        if len(string) < 50 and 'final score' in string.lower():
            home, away, home_score, away_score = get_final_score(string)

    if i > 0: # represents a successful parse
        home_breakdown = parse_scores(scores[0])
        away_breakdown = parse_scores(scores[1])
        try:
            check_scores(home_breakdown,home,home_score)
            check_scores(away_breakdown,away,away_score)
        except:
            print ' *** Error, maybe home/away are not defined?'
            set_trace()
        return {'date':date, 'home':home_breakdown, 'away':away_breakdown}
    else:
        return None


def check_scores(breakdown,team,final_score):
    if breakdown['team'] != team:
        print " *** Team name doesn't match"
        set_trace()
    summary = summarize_game(breakdown)
    if 5 * summary['tries'] + 3 * summary['penalties'] + 3 * summary['dropgoals'] + 2 * summary['conversions'] != final_score:
        print " *** Scores don't match"
        set_trace()


def summarize_game(breakdown):
    def total(xs):
        return sum([n for (player,n) in xs])
    score = breakdown['score']
    result = {}
    result['tries'] = total(score['tries'])
    result['penalties'] = total(score['penalties'])
    result['conversions'] = total(score['conversions'])
    result['dropgoals'] = total(score['dropgoals'])
    return result


# def is_terminal(string):
#     terminals = ['Match Officials','Team','']
#     return any([s in string for s in terminals])


def contains_team_name(string):
    team_names = ['Blues','Brumbies','Bulls','Cheetahs','Chiefs','Crusaders','Force','Highlanders','Hurricanes','Lions','Rebels','Reds','Sharks','Stormers','Waratahs']
    return any([s in string for s in team_names])


def is_try(string):
    return 'Try' in string or 'Tries' in string


def is_pen(string):
    return 'Pen' in string and 'Penalty try' not in string


def is_con(string):
    return 'Con' in string


def is_drop(string):
    return 'Drop' in string


def is_card(string):
    return 'Cards' in string


def parse_scores(dictionary):
    '''
    This function takes a <p> or <div> element describing a team's scoring over
    the course of a game, and extracts the number of tries, penalties,
    conversions and drop goals.
    '''

    from collections import defaultdict

    team = get_team_name(dictionary['team'])

    score = {}

    for key in ['tries','penalties','conversions','dropgoals']:
        score[key] = get_numbers(get_name_list(dictionary[key]))

    return {'team' : team, 'score' : score}


def get_name_list(string):
    if ':' in string:
        return drop_up_to_1st(':',string).strip().split(',')
    elif '-' in string:
        return drop_up_to_1st('-',string).strip().split(',')
    else:
        return []


def drop_up_to_1st(c,string):
    for i, x in enumerate(string):
        if x == c:
            break
    return string[i+1:]


def get_team_name(s):
    team = s.strip().encode('ascii','ignore')
    if team.startswith('For the '):
        team = team.lstrip('For the ')
    if team.endswith(':'):
        team = team.rstrip(':')
    if team.endswith('-'):
        team = team.rstrip('-')
    return team.strip()


def get_final_score(string):
    split_string = string.replace('Final Score','').split()
    if len(split_string) == 4:
        shift = 0
    elif len(split_string) == 6:
        shift = 1
    else:
        print ' *** Unusual final score line'
        set_trace()
    home      = split_string[0]
    homescore = int(split_string[1])
    away      = split_string[2+shift]
    awayscore = int(split_string[3+shift])
    return home, away, homescore, awayscore


def strip_parens(s):
    return s.lstrip('(').rstrip(')')


def get_numbers(xs):
    '''
    This function takes a string consisting of a player name possibly followed by
    a number, and splits off the number (or uses '1' when there is no number at
    the end). For example:

    >>> get_numbers('J Hobbs 2')  => ('J Hobbs', 2)
    >>> get_numbers('M Keane')    => ('M Keane', 1)
    '''

    def get_number(s):
        tokens = s.split(' ')
        for c in tokens:
            try:
                n = int(strip_parens(c))
                tokens.remove(c)
                return ' '.join(tokens), n
            except:
                pass
        return s, 1

    return [get_number(x) for x in xs if x]

# if __name__ == '__main__':
#     run()


