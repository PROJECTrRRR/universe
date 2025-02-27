#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

# Display services
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Get valid service selection
while true; do
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z "$SERVICE_NAME" ]]; then
    echo "I could not find that service. What would you like today?"
    echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  else
    break
  fi
done

# Get customer phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If customer doesn't exist, get their name
if [[ -z "$CUSTOMER_NAME" ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
fi

# Get appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Get customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Insert appointment
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Confirm appointment
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
