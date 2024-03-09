#!/bin/bash

# PSQL variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# first and foremost prompt the user for their username
echo "Enter your username:"

# read the input of the user
read USERNAME

# retrieve the users information from the database
USERNAME_RESULT=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")

# retrieve the users id (since it is a primary id, each one is unique)
USER_ID_RESULT=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")

# if the player is NOT found
if [[ -z $USERNAME_RESULT ]]
then

  # greet the player
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  # then add the player to the database
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
else
  # retrieve the games played
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN players USING(user_id) WHERE username='$USERNAME'")

  # retrieve their best game
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games LEFT JOIN players USING(user_id) WHERE username='$USERNAME'")

  # tell the user welcome back and their details
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi

# generate a random number (between 1 to 1000)
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# a variable that stores the number of guesses
GUESS_COUNT=0

# ask the user for a guess
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

# loop that prompts the user to guess until it is correct
until [[ $USER_GUESS == $SECRET_NUMBER ]]
do
  # will check if the guess is a valid input
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    # tell them to put a valid input
    echo "That is not an integer, guess again:"
    read USER_GUESS

    # update guess count
    ((GUESS_COUNT++))

  # ELSE if it's a valid guess
  else
    # check inequalities and give a hint
    if [[ $USER_GUESS < $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      read USER_GUESS

      # update guess count
      ((GUESS_COUNT++))
    else
      echo "It's lower than that, guess again:"
      read USER_GUESS

      # update guess count
      ((GUESS_COUNT++))
    fi
  fi
done

# loop ends when guess is correct so, update guess
((GUESS_COUNT++))

# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")

# add their result to the game table
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, secret_number, number_of_guesses) VALUES($USER_ID_RESULT, $SECRET_NUMBER, $GUESS_COUNT)")

# display winning message to user
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
