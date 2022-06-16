#!/bin/bash

echo 'Deprecated. Please use the daily_beauty_notifier.py instead.'
exit 1;

echo 'Check required commands has been started!'

which unzip 2>&1 > /dev/null

if [[ $? != 0 ]]; then
    echo 'Please install unzip package!'
    exit 1;
fi;

which wget 2>&1 > /dev/null

if [[ $? != 0 ]]; then
    echo 'Please install wget package!'
    exit 1;
fi;

which curl 2>&1 > /dev/null

if [[ $? != 0 ]]; then
    echo 'Please install curl package!'
    exit 1;
fi;

which csvtool 2>&1 > /dev/null

if [[ $? != 0 ]]; then
   echo 'Please install csvtool package!'
   exit 1;
fi;

if [[ ! -d "${HOME}/.nvm/" ]]; then
    echo "Please install NVM scrit firstly!"

    exit 1;
fi;

source "${HOME}/.nvm/nvm.sh" && which html-minifier 2>&1 > /dev/null

if [[ $? != 0 ]]; then
    which node 2>&1 > /dev/null

    if [[ $? != 0 ]]; then
        echo "Please install nvm and install current Node.js version!"

        exit 1;
    fi;

    which npm 2>&1 > /dev/null

    if [[ $? != 0 ]]; then
        echo "Then using npm command to install the html-minifier!"

        exit 1;
    fi;

    echo "You may try to use html_minifier_installer.sh Bash script firstly!"

    exit 1;
fi;

if [[ $1 == "" ]]; then
    echo 'Please set contact mail address!'
    echo 'Set default mail address......'
    mail_address="admin@mail.com"
else
    mail_address=$1
fi;

yesterday_date=$(date --date="-1 Day" "+%F")
today_date=$(date "+%F")

echo "Fetch Previous Day (${yesterday_date}) has been started!"

source_url_path=${PWD}"/beauty_sources.csv"

if [[ ! -f ${source_url_path} ]]; then
    echo "Cannot find ${source_url_path}!"
    exit 1;
fi;

source_name=$(csvtool format '%(1)\n' ${source_url_path})
source_url=$(csvtool format '%(2)\n' ${source_url_path})

if [[ ${source_name} != 'ck101.com' ]]; then
    echo "It only supports ck101 for now!"
    exit 1;
fi;

page=1
pagination_format="3866-${page}"
source_host="https://"${source_name}

limit_counts=3
current_source_url=${source_url}
current_post_info_datelines_count=0

declare -a post_url_array
declare -a post_title_array
declare -a post_image_array
declare -a post_content_array

for limit_count in $(seq 2 ${limit_counts});
do
    curl --silent ${current_source_url} > index.html
    post_info_datelines_count=$(cat index.html | grep -c "<span class=\"postInfo_dateline\">${yesterday_date}")
    today_post_info_datelines_count=$(cat index.html | grep -c "<span class=\"postInfo_dateline\">${today_date}")
    total_count=$((${post_info_datelines_count}+${today_post_info_datelines_count}))

    post_urls=$(cat index.html | grep -o -P '<a class="s xst" href="/thread-(\w+)-1-1.html' | sed -e 's/<a class="s xst" href="//g' | head -n ${total_count} | tail -n ${post_info_datelines_count})
    post_titles=$(cat index.html | grep -P '<a class="s xst" href="/thread-(\w+)-1-1.html' | sed -e 's/<a class="s xst" href="//g' | head -n ${total_count} | tail -n ${post_info_datelines_count} | grep -o -P ">.*<\/a>" | sed -e 's/[ <\/a>]//g')

    if [[ ${post_info_datelines_count} == 0 ]]; then
        echo 'Fetching is done!'
        break;
    else
        current_post_info_datelines_count=$((${current_post_info_datelines_count}+${post_info_datelines_count}))
    fi;

    for post_title in ${post_titles};
    do
        post_title_array+=("${post_title}")
    done;

    for post_url in ${post_urls};
    do
        curl --silent ${source_host}${post_url} > post.html

        post_image_url=$(cat post.html | grep -o -P 'file="(\w+).*.png' | sed -e 's/file="//g' | head -n 1)
        post_description="<a href='${source_host}${post_url}' style='color: #333333' target='_blank'>看更多</a>"

        if [[ ${post_image_url} == "" ]]; then
            post_image_url=$(cat post.html | grep -o -P 'file="(\w+).*.jpg' | sed -e 's/file="//g' | head -n 1)
        fi;

        post_image_array+=("${post_image_url}")
        post_url_array+=("${post_url}")
        post_content_array+=("${post_description}")
    done;

    for post_image in ${post_images};
    do
        echo ${post_image}
    done;

    current_source_url=$(echo ${source_url} | sed -e "s/${pagination_format}/3866-${limit_count}/g")

done;

echo "Check today has has the contents..."

if [[ ${post_url_array[0]} == "" ]]; then
    echo "It has not latest contents on ${yesterday_date}"
    exit 0;
fi;

echo "Generate Email Template..."

three_columns=3

row_numbers=$((${current_post_info_datelines_count}/${three_columns}))
remainder_numbers=$((${current_post_info_datelines_count}%${three_columns}))

rm -rf $PWD"/antwort/"
rm -f $PWD"/master.zip"

echo 'Downloading Email Templates...'

wget -q -nv https://github.com/open-source-contributions/antwort/archive/master.zip

if [[ ! -f $PWD"/master.zip" ]]; then
    echo 'Download antwort-master ZIP file is failed...'
    exit 1;
fi;

unzip -qq master.zip

mv antwort-master/ antwort/

email_skeleton=$(cat ${PWD}"/antwort/three-cols-images/build.html")
email_one_grid_with_no_title=$(cat ${PWD}"/antwort/three-cols-images/one_grids_with_no_title.html")
email_two_grids_with_no_title=$(cat ${PWD}"/antwort/three-cols-images/two_grids_with_no_title.html")
email_one_grid_with_title=$(cat ${PWD}"/antwort/three-cols-images/one_grids_with_title.html")
email_two_grids_with_title=$(cat ${PWD}"/antwort/three-cols-images/two_grids_with_title.html")
email_three_grids_with_no_title=$(cat ${PWD}"/antwort/three-cols-images/three_grids_with_no_title.html")
email_three_grids_with_title=$(cat ${PWD}"/antwort/three-cols-images/three_grids_with_title.html")

app_name="Daily Beauty"
service_name=${app_name}
contact_name="Peter"
app_tw_name="正妹日報 (${yesterday_date})"
version="v1.0"

echo 'Replace Email information contents has been started...'

email_skeleton=$(echo ${email_skeleton} | sed -e "s/Three columns with images/${app_name}/g")
email_skeleton=$(echo ${email_skeleton} | sed -e "s/{{service_name}}/${service_name}/g")
email_skeleton=$(echo ${email_skeleton} | sed -e "s/{{version}}/${version}/g")
email_skeleton=$(echo ${email_skeleton} | sed -e "s/{{contact_name}}/${contact_name}/g")
email_skeleton=$(echo ${email_skeleton} | sed -e "s/{{mail_address}}/${mail_address}/g")

email_contents=""
email_final_templates=""

echo 'Replace Email image,title and description contents has been started...'

if [[ ${row_numbers} == 1 ]]; then
    email_contents=$(echo ${email_three_grids_with_title} | sed -e "s/{{main_title}}/${app_tw_name}/g")

    tmp_email_contents=$(echo ${email_contents} | sed -e "s@{{image_link_1}}@${post_image_array[0]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{image_link_2}}@${post_image_array[1]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{image_link_3}}@${post_image_array[2]}@g")

    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_1}}@${post_title_array[0]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_2}}@${post_title_array[1]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_3}}@${post_title_array[2]}@g")

    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_1}}@${post_content_array[0]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_2}}@${post_content_array[1]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_3}}@${post_content_array[2]}@g")

    email_contents=${tmp_email_contents}
fi;

if [[ ${row_numbers} == 0 ]]; then
    if [[ ${remainder_numbers} == 1 ]]; then
        email_contents=$(echo ${email_one_grid_with_title} | sed -e "s/{{main_title}}/${app_tw_name}/g")

        tmp_email_contents=$(echo ${email_contents} | sed -e "s@{{image_link_1}}@${post_image_array[0]}@g")

        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_1}}@${post_title_array[0]}@g")

        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_1}}@${post_content_array[0]}@g")
    fi;

    if [[ ${remainder_numbers} == 2 ]]; then
        email_contents=$(echo ${email_two_grids_with_title} | sed -e "s/{{main_title}}/${app_tw_name}/g")

        tmp_email_contents=$(echo ${email_contents} | sed -e "s@{{image_link_1}}@${post_image_array[0]}@g")
        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{image_link_2}}@${post_image_array[1]}@g")

        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_1}}@${post_title_array[0]}@g")
        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_2}}@${post_title_array[1]}@g")

        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_1}}@${post_content_array[0]}@g")
        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_2}}@${post_content_array[1]}@g")
    fi;

    email_contents=${tmp_email_contents}
fi;

if [[ ${row_numbers} -ge 2 ]]; then
    email_contents=$(echo ${email_three_grids_with_title} | sed -e "s/{{main_title}}/${app_tw_name}/g")

    tmp_email_contents=$(echo ${email_contents} | sed -e "s@{{image_link_1}}@${post_image_array[0]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{image_link_2}}@${post_image_array[1]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{image_link_3}}@${post_image_array[2]}@g")

    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_1}}@${post_title_array[0]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_2}}@${post_title_array[1]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_3}}@${post_title_array[2]}@g")

    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_1}}@${post_content_array[0]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_2}}@${post_content_array[1]}@g")
    tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_3}}@${post_content_array[2]}@g")

    row_numbers=$((${row_numbers}-1))
    index_one=$((${three_columns}))
    index_two=$((${three_columns}+1))
    index_three=$((${three_columns}+2))

    tmp_final_email_contents=${tmp_email_contents}

    for row_number in $(seq 1 ${row_numbers});
    do
        tmp_no_title_email_contents=$(echo ${email_three_grids_with_no_title} | sed -e "s@{{image_link_1}}@${post_image_array[${index_one}]}@g")
        tmp_no_title_email_contents=$(echo ${tmp_no_title_email_contents} | sed -e "s@{{image_link_2}}@${post_image_array[${index_two}]}@g")
        tmp_no_title_email_contents=$(echo ${tmp_no_title_email_contents} | sed -e "s@{{image_link_3}}@${post_image_array[${index_three}]}@g")

        tmp_no_title_email_contents=$(echo ${tmp_no_title_email_contents} | sed -e "s@{{Title_1}}@${post_title_array[${index_one}]}@g")
        tmp_no_title_email_contents=$(echo ${tmp_no_title_email_contents} | sed -e "s@{{Title_2}}@${post_title_array[${index_two}]}@g")
        tmp_no_title_email_contents=$(echo ${tmp_no_title_email_contents} | sed -e "s@{{Title_3}}@${post_title_array[${index_three}]}@g")

        tmp_no_title_email_contents=$(echo ${tmp_no_title_email_contents} | sed -e "s@{{Content_1}}@${post_content_array[${index_one}]}@g")
        tmp_no_title_email_contents=$(echo ${tmp_no_title_email_contents} | sed -e "s@{{Content_2}}@${post_content_array[${index_two}]}@g")
        tmp_no_title_email_contents=$(echo ${tmp_no_title_email_contents} | sed -e "s@{{Content_3}}@${post_content_array[${index_three}]}@g")

        index_one=$((${index_three}+1))
        index_two=$((${index_three}+2))
        index_three=$((${index_three}+3))

        tmp_final_email_contents=${tmp_final_email_contents}${tmp_no_title_email_contents}
    done;

    if [[ ${remainder_numbers} == 1 ]]; then
        tmp_email_contents=$(echo ${email_one_grid_with_no_title} | sed -e "s@{{image_link_1}}@${post_image_array[${index_one}]}@g")

        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_1}}@${post_title_array[${index_one}]}@g")

        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_1}}@${post_content_array[${index_one}]}@g")

        tmp_final_email_contents=${tmp_final_email_contents}${tmp_email_contents}
    fi;

    if [[ ${remainder_numbers} == 2 ]]; then
        email_contents=$(echo ${email_two_grids_with_no_title} | sed -e "s/{{main_title}}/${app_tw_name}/g")

        tmp_email_contents=$(echo ${email_contents} | sed -e "s@{{image_link_1}}@${post_image_array[${index_one}]}@g")
        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{image_link_2}}@${post_image_array[${index_two}]}@g")

        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_1}}@${post_title_array[${index_one}]}@g")
        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Title_2}}@${post_title_array[${index_two}]}@g")

        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_1}}@${post_content_array[${index_one}]}@g")
        tmp_email_contents=$(echo ${tmp_email_contents} | sed -e "s@{{Content_2}}@${post_content_array[${index_two}]}@g")

        tmp_final_email_contents=${tmp_final_email_contents}${tmp_email_contents}
    fi;

    email_contents=${tmp_final_email_contents}
fi;

echo "Sending e-mail via sendinblue_sender.sh..."

email_final_templates=$(echo ${email_skeleton} | sed -e "s@{{Email_Contents_Here}}@${email_contents}@g")

echo ${email_final_templates} > html_template.html

echo "Minify email template..."

source "${HOME}/.nvm/nvm.sh" && html-minifier \
    --collapse-whitespace \
    --remove-comments \
    --remove-optional-tags \
    --remove-redundant-attributes \
    --remove-script-type-attributes \
    --remove-tag-whitespace \
    --use-short-doctype \
    --minify-css true \
    ${PWD}/html_template.html > minified_html_template.html

email_final_templates=$(cat ${PWD}/minified_html_template.html)

./sendinblue_sender.sh "${email_final_templates}" 2>&1 > "sendinblue_result_"$(date "+%F")".txt"

echo "Clean/Remove unecessary files..."
rm -f index.html
rm -f post.html
rm -f html_template.html
rm -f minified_html_template.html
rm -f master.zip
