# Copyright (c) 2020 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#!/bin/bash
URL_TAIL=$1

if [ -z ${URL_TAIL} ]
then
	URL_TAIL=operator/latest/domains
	echo " URL_TAIL set to default $URL_TAIL"
else
	echo " URL_TAIL set to $URL_TAIL"	
fi

REST_PORT=`kubectl get services -n operator-ns -o jsonpath='{.items[?(@.metadata.name == "external-weblogic-operator-svc")].spec.ports[?(@.name == "rest")].nodePort}'`
REST_ADDR="https://${HOSTNAME}:${REST_PORT}"
SECRET=`kubectl get serviceaccount operator-sa -n operator-ns -o jsonpath='{.secrets[0].name}'`
ENCODED_TOKEN=`kubectl get secret ${SECRET} -n operator-ns -o jsonpath='{.data.token}'`
TOKEN=`echo ${ENCODED_TOKEN} | base64 --decode`
#OPERATOR_CERT_DATA=`kubectl get secret -n operator-ns weblogic-operator-identity -o jsonpath='{.data.tls\.crt}'`
#OPERATOR_CERT_FILE="/tmp/operator.cert.pem"
#echo ${OPERATOR_CERT_DATA} | base64 --decode > ${OPERATOR_CERT_FILE}
#cat ${OPERATOR_CERT_FILE}

echo "Ready to call operator REST APIs"

#URL_TAIL=operator/latest/domains

STATUS_CODE=`curl \
  -v \
  -k \
  -H "Authorization: Bearer ${TOKEN}" \
  -H Accept:application/json \
  -X GET ${REST_ADDR}/${URL_TAIL} \
  -o curlget.out \
  --stderr curlget.err \
  -w "%{http_code}"`

cat curlget.err
cat curlget.out | jq .
