#!/usr/bin/env bash

set -eo pipefail


if [ -z $GHTOKEN ]; then
    >&2 echo -e "\033[1;31mMissing Github Token(GHTOKEN)! Please get a BotToken from 'Github Settings->Developer settings->Personal access tokens' and set it in Repo Secrect\033[0m"
    exit 1
fi

if [ -z $BOTTOKEN ]; then
    >&2 echo -e "\033[1;31mMissing Bot Token(BOTTOKEN)! Please get a BotToken from @Botfather on Telegram and set it in Repo Secrect\033[0m"
    exit 2
fi

if [ -z $CHATIDS ]; then
    >&2 echo -e "\033[1;31mMissing ChatIds(CHATIDS)! Please get ChatId from @GroupIDbot on Telegram Chats(Muti chatids split with comma ',') and set it in Repo Environment Values\033[0m"
    exit 2
fi

function login_gh() {
    printf "#%.0s" {1..60}
    echo 
    echo -e "## \033[1;33mLogin to github to use github-cli...\033[0m"
    printf "#%.0s" {1..60}
    echo 

    echo $GHTOKEN > WeChatSetup/temp/GHTOKEN
    gh auth login --with-token < WeChatSetup/temp/GHTOKEN
    if [ "$?" -ne 0 ]; then
        >&2 echo -e "\033[1;31mLogin Failed, please check your network or token!\033[0m"
        clean_data 1
    fi
    rm -rfv WeChatSetup/temp/GHTOKEN
}

### https://kodango.com/sed-and-awk-notes-part-5
## start=${1:-""} means as follows in general
## if ($1) then
## start=$1
## else
## start=""
## end
function join_lines() {
     local delim=${1:-,}
     sed 'H;$!d;${x;s/^\n//;s/\n/\'$delim'/g}'
}

function clean_data() {
    printf "#%.0s" {1..60}
    echo 
    echo -e "## \033[1;33mClean runtime and exit...\033[0m"
    printf "#%.0s" {1..60}
    echo 

    rm -rfv WeChatSetup/*
    exit $1
}

function main() {
    temp_path="WeChatSetup/temp"
    mkdir -p ${temp_path}

    login_gh

    gh release view  --json body --jq ".body" > ${temp_path}/release.info

    release_info=`awk '!/^$|Sha256/ { $1="*"$1"*";sub("UpdateTime", "CheckTime"); if ( match($2, /https?:\/\/([\w\.\/:])*/) ) $2="[Url]("$2")"; print $0 }' ${temp_path}/release.info | join_lines '%0A' | sed 's/ /%20/g'`
    dest_version=`awk '/DestVersion/ { print $2 }' ${temp_path}/release.info`
    release_info="$release_info%0A%0A*NotifyFrom:*%20[Github](https://github.com/tom-snow/wechat-windows-versions/releases/tag/v$dest_version)"

    echo $CHATIDS | sed 's/,/\n/g' > ${temp_path}/chat_ids
    # while IFS="" read -r chatid || [ -n "$chatid" ]
    while IFS="" read -r chatid
    do
        api_link="https://api.telegram.org/bot$BOTTOKEN/sendMessage?chat_id=$chatid&text=*New%20WeChat%20Windows%20Version!!*%0A%0A$release_info&parse_mode=Markdown&disable_web_page_preview=true"
        curl -s -o /dev/null $api_link
    done < ${temp_path}/chat_ids

    gh auth logout --hostname github.com | echo "y"
    clean_data 0
}

main