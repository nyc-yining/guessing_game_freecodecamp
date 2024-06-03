#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME_START(){
    echo "Enter your username:"
    read USER_NAME

    USER_ID=$($PSQL "select user_id from users where username='$USER_NAME'")
    
    if [[ $USER_ID ]]
    then
        GAME_COUNT=$($PSQL "select count(user_id) from games where user_id=$USER_ID")
        BEST_SCORE=$($PSQL "select min(guesses) from games where user_id=$USER_ID")
        echo -e "\nWelcome back, $USER_NAME! You have played $GAME_COUNT games, and your best game took $BEST_SCORE guesses."
    else
        echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
        INSERT_USER=$($PSQL "insert into users(username) values('$USER_NAME')")
        USER_ID=$($PSQL "select user_id from users where username='$USER_NAME'")
    fi
    COMPARE
}

COMPARE(){
  GUESS_NUMBER=$(( RANDOM % 1000 + 1 ))
  GAME_GUESSED=0
  TRIES=0

  echo -e "\nGuess the secret number between 1 and 1000:"

  while [[ $GAME_GUESSED = 0 ]]
  do
    read USER_GIVEN_NUMBER
    if [[ ! $USER_GIVEN_NUMBER =~ ^[0-9]+$ ]]
    then 
        echo "That is not an integer, guess again:"
    else
        if [[ $USER_GIVEN_NUMBER = $GUESS_NUMBER ]]
        then 
            TRIES=$(( $TRIES + 1 ))
            echo "You guessed it in $TRIES tries. The secret number was $GUESS_NUMBER. Nice job!"
            INSERT_SCORE=$($PSQL "insert into games(user_id,guesses) values($USER_ID,$TRIES)")
            GAME_GUESSED=1
        elif [[ $USER_GIVEN_NUMBER -gt $GUESS_NUMBER ]]
        then 
            echo -e "\nIt's higher than that, guess again:"
            TRIES=$(( $TRIES + 1 ))
        else
            echo -e "\nIt's lower than that, guess again:"
            TRIES=$(( $TRIES + 1 ))
        fi
    fi
  done
}

GAME_START