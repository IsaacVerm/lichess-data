# extract values
jq -r '[.opening.eco, .opening.name, .opening.ply] | @csv' data/games.ndjson >> data/openings.csv

# remove duplicates
sort -u data/openings.csv -o data/openings.csv

# create header
# header is added now instead of before because if not it might be deleted when removing duplicates with sort -u
sed '1i eco,name,ply' data/openings.csv > data/openings.csv.tmp && mv data/openings.csv.tmp data/openings.csv

# some ECOs appear multiple times
# for example C00 refers to all variations of the French Defense
# French Defense: St. George Defense, French Defense: Carlson Gambit
# to keep things simple I just keep the ECO code with the lowest ply number
# that's the most basic one
sqlite-utils memory data/openings.csv "select * from openings group by eco having min(ply)" --csv > data/openings.csv.tmp && mv data/openings.csv.tmp data/openings.csv