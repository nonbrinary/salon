#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Salon Appointment Scheduler ~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "What can I help you with today?"
  
  SERVICE_LIST=$($PSQL "SELECT * FROM services")
  SERVICE_LIST_FORMATTED=$(echo $SERVICE_LIST | sed 's/ |/)/g')
  echo "$SERVICE_LIST_FORMATTED"
  echo "4) Exit"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SCHEDULE_MENU ;;
    2) SCHEDULE_MENU ;;
    3) SCHEDULE_MENU ;;
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid option."
  esac

}

SCHEDULE_MENU() {

  #get customer's phone number
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #if name not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get customer name if not in table
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

    #display whether customer was added
    if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
    then
      echo -e "\n$CUSTOMER_NAME added to database."
    fi
  fi

  #get requested service time
  echo -e "\nWhat time would you like your appointment for?"
  read SERVICE_TIME

  #get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #set appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  #get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  #display result
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//')."
  fi

}

EXIT() {
  echo -e "\nThank you for coming in!"
}

MAIN_MENU