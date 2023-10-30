#! /bin/sh

if [ -z $1 ]; then
  echo "usage: bash get_a_domain.sh NAME_OF_DOMAIN_HERE.com"
  exit 1
fi

DOMAIN=$(python -c "import uuid; print(uuid.uuid4())")-$1
AVAILABILITY=$(aws route53domains check-domain-availability --region us-east-1 --domain-name $DOMAIN | jq '.Availability')

if [ $AVAILABILITY != "\"UNAVAILABLE\"" ];
  then
    echo "grab it!"
    echo "the domain would be $DOMAIN"
else
  echo "can't grab it..."
fi
