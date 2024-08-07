#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Read CSV and insert unique teams
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year != "year" ]]; then # Skip header line
    # Insert unique teams
    for TEAM in "$winner" "$opponent"
    do
      # Use double quotes to prevent issues with spaces or special characters in team names
      $PSQL "INSERT INTO teams (name) VALUES ('$TEAM') ON CONFLICT (name) DO NOTHING"
    done

    # Insert game data
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

    # Use double quotes to handle any special characters in the round name
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)"
  fi
done < games.csv
