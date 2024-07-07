#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"

MAIN() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #echo select services menu
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  #read input select service id
  read SERVICE_ID_SELECTED
  FORMATTED_SERVICE_ID_SELECTED=$(echo $SERVICE_ID_SELECTED | sed -E 's/[a-z]| //g')
  if [[ ! $FORMATTED_SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    FORMATTED_SERVICE_ID_SELECTED=0
  fi
  CHECK_SSI=$($PSQL "SELECT service_id FROM services WHERE service_id = $FORMATTED_SERVICE_ID_SELECTED")
  if [[ -z $CHECK_SSI ]]
  then
    MAIN "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    FORMATTED_PHONE=$(echo $CUSTOMER_PHONE | sed -E 's/([0-9]|-)|([a-z]| )/\1/g')
    #check whether user exist
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$FORMATTED_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$FORMATTED_PHONE', '$CUSTOMER_NAME')")
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$FORMATTED_PHONE'")
    FORMATTED_CUSTOMER_ID=$(echo $CUSTOMER_ID | sed -E 's/^ *| *$//g')
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $FORMATTED_CUSTOMER_ID")
    FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
    
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $FORMATTED_SERVICE_ID_SELECTED")
    FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
    
    echo -e "\nWhat time would you like your $FORMATTED_SERVICE_NAME, $FORMATTED_CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($FORMATTED_CUSTOMER_ID, $FORMATTED_SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."
  fi
}

MAIN