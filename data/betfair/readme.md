## Betfair data

Betfair data files are stored in .csv format, typically one week or one month per file.

## Fields

*SPORTS_ID* - integer identifying the type of event (see lookup table at end of document)

*EVENT_ID* - integer event id

*SETTLED_DATE* - datetime in `dd/mm/yyyy HH:MM` format specifying when the bet was settled

*FULL DESCRIPTION* - text description of the event.

*SCHEDULED_OFF* - datetime in `dd/mm/yyyy HH:MM` format specifying when the event started

*EVENT* - what type of bet is this?

*DT ACTUAL_OFF* - datetime specifying when the event actually started.

*SELECTION_ID* - integer identifying the selection for this market

*SELECTION* - text description of the selection for this market

*ODDS* - what odds were being offered on this market?

*NUMBER_BETS* - how many bettors were at this level?

*VOLUME_MATCHED* - total amount matched at this level (in GBP)

*LATEST_TAKEN* - when was the latest time someone took a bet at this level

*FIRST_TAKEN* - when was the earliest time someone took a bet at this level

*WIN_FLAG* - was this a winning bet?

*IN_PLAY* - is the market in play?

## Sport ids

1 Soccer
2 Tennis
3 Golf
4 Cricket
5 Rugby Union
6 Boxing
7 Horse Racing
8 Motor Sport
10 Special Bets
11 Cycling
12 Rowing
13 Horse Racing - Todays Card
14 Soccer - Fixtures
15 Greyhound - Todays Card
1477 Rugby League
3503 Darts
3988 Athletics
4339 Greyhound Racing
6231 Financial Bets
6422 Snooker
6423 American Football
7511 Baseball
7522 Basketball
7523 Hockey
7524 Ice Hockey
7525 Sumo Wrestling
61420 Australian Rules
66598 Gaelic Football
66599 Hurling
72382 Pool
136332 Chess
256284 Trotting
300000 Commonwealth Games
315220 Poker
451485 Winter Sports
468328 Handball
627555 Badminton
678378 International Rules
982477 Bridge
998917 Volleyball
998919 Bowls
998920 Floorball
606611 Netball
998916 Yachting
620576 Swimming
1444073 Exchange Poker
1938544 Backgammon
2030972 GAA Sports
2152880 Gaelic Games
2264869 International Markets
2378961 Politics