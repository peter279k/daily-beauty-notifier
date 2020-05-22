#!/bin/bash

if [[ ${sendinblue_api_key} == '' ]]; then
    echo "Please set SendinBlue API key as a environment variable"

    exit 1;
fi;

email_address_lists=${PWD}"/mail_addresses.txt"
if [[ ! -f ${email_address_lists} ]]; then
    echo "Cannot find ${email_address_lists}!"
    exit 1;
fi;

email_setting_lists=${PWD}"/mail_setting.csv"
if [[ ! -f ${email_setting_lists} ]]; then
    echo "Cannot find ${email_setting_lists}!"
    exit 1;
fi;

echo "Check mail_setting.csv content format..."

mail_setting_count=$(cat ${email_setting_lists} | wc -l)

if [[ ${mail_setting_count} != 3 ]]; then
    echo 'The mail setting count should be 3.'
    exit 1;
fi;

declare -a first_column_array
declare -a second_column_array

first_columns=$(csvtool format '%(1)\n' ${email_setting_lists})
second_columns=$(csvtool format '%(2)\n' ${email_setting_lists})

echo "Check first column...."

for first_column in ${first_columns};
do
    first_column_array+=(${first_column})
done;

if [[ ${first_column_array[0]} != 'subject' ]]; then
    echo 'The first field on first column should be "subject"!'

    exit 1;
fi;

if [[ ${first_column_array[1]} != 'sender_name' ]]; then
    echo 'The second field on first column should be "sender_name"!'

    exit 1;
fi;

if [[ ${first_column_array[2]} != 'sender_email' ]]; then
    echo 'The third field on first column should be "sender_email"!'

    exit 1;
fi;

echo "Check second column...."

for second_column in ${second_columns};
do
    second_column_array+=(${second_column})
done;

if [[ ${second_column_array[0]} == '' ]]; then
    echo 'The first field on second column should not be empty!'

    exit 1;
fi;

if [[ ${second_column_array[1]} == '' ]]; then
    echo 'The second field on second column should not be empty!'

    exit 1;
fi;

check_email_format=$(echo ${second_column_array[2]} | grep -c -E "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,9}\b")
if [[ ${check_email_format} == 0 ]]; then
    echo 'The third field on second column should be email format!'

    exit 1;
fi;

email_final_templates=$1

if [[ ${email_final_templates} == '' ]]; then
    echo 'Please set HTML email template!'
    exit 1;
fi;

email_final_templates=$(echo ${email_final_templates} | sed -e "s/\"/'/g")
today_date=$(date "+%F")
subject=$(echo ${second_column_array[0]} | sed -e "s/today_date/${today_date}/g")
sender_name=${second_column_array[1]}
sender_email=${second_column_array[2]}

post_data_template="{
   \"sender\":{
      \"name\":\"{{sender_name}}\",
      \"email\":\"{{sender_email}}\"
   },
   \"to\":[
      {
         \"email\":\"{{to_email}}\",
         \"name\":\"{{to_name}}\"
      }
   ],
   \"subject\":\"{{subject}}\",
   \"htmlContent\":\"${email_final_templates}\"
}"

for mail_address in $(cat ${email_address_lists});
do
    receiver_name=$(echo ${mail_address} | awk '{split($1,a,"@"); print a[1]}')

    post_data=$(echo ${post_data_template} | sed -e "s/{{sender_name}}/${sender_name}/g")
    post_data=$(echo ${post_data} | sed -e "s/{{sender_email}}/${sender_email}/g")
    post_data=$(echo ${post_data} | sed -e "s/{{subject}}/${subject}/g")
    post_data=$(echo ${post_data} | sed -e "s/{{to_email}}/${mail_address}/g")
    post_data=$(echo ${post_data} | sed -e "s/{{to_name}}/${receiver_name}/g")

    curl --silent --request POST \
        --url https://api.sendinblue.com/v3/smtp/email \
        --header 'accept: application/json' \
        --header "api-key:${sendinblue_api_key}" \
        --header 'content-type: application/json' \
        --data "${post_data}"
done;
