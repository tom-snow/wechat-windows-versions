#!/usr/bin/env bash
# 已废弃

set -eo pipefail

temp_path="WeChatSetup/temp"
latest_path="WeChatSetup/latest"

function install_depends () {
    printf "#%.0s" {1..60}
    echo 
    echo -e "## \033[1;33mInstalling 7zip, shasum, wget, curl, git\033[0m"
    printf "#%.0s" {1..60}
    echo 
    apt install -y p7zip-full p7zip-rar libdigest-sha-perl wget curl git
}

function download_wechat() {
    printf "#%.0s" {1..60}
    echo 
    echo -e "## \033[1;33mDownloading the newest WechatSetup...\033[0m"
    printf "#%.0s" {1..60}
    echo 
    wget https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe -O ${temp_path}/WeChatSetup.exe
    if [ "$?" -ne 0 ]; then
        >&2 echo -e "\033[1;31mDownload Failed, please check your network!\033[0m"
        exit 1
    fi
}

function extract_version() {
    printf "#%.0s" {1..60}
    echo 
    echo -e "## \033[1;33mExtract WechatSetup, get the dest version of wechat\033[0m"
    printf "#%.0s" {1..60}
    echo 
    mkdir -p ${temp_path}/temp
    local outfile=`7z l ${temp_path}/WeChatSetup.exe | grep improve.xml | awk 'NR ==1 { print $NF }'`
    # 7z x ${temp_path}/WeChatSetup.exe -o${temp_path}/temp "\$R5/Tencent/WeChat/improve.xml"
    7z x ${temp_path}/WeChatSetup.exe -o${temp_path}/temp $outfile
    dest_version=`awk '/MinVersion/{ print $2 }' ${temp_path}/temp/$outfile | sed -e 's/^.*="//g' -e 's/".*$//g'`
    rm -rfv ${temp_path}/temp
}


# rename and replace
function prepare_commit() {
    printf "#%.0s" {1..60}
    echo 
    echo -e "## \033[1;33mPrepare to commit new version and clean runtime\033[0m"
    printf "#%.0s" {1..60}
    echo 
    mkdir -p WeChatSetup/$dest_version
    cp $temp_path/WeChatSetup.exe WeChatSetup/$dest_version/WeChatSetup-$dest_version.exe
    echo "$now_sum256 WeChatSetup-$dest_version.exe" > WeChatSetup/$dest_version/WeChatSetup-$dest_version.exe.sha256

    cp $temp_path/WeChatSetup.exe WeChatSetup/latest/WeChatSetup-latest.exe
    echo "$now_sum256 WeChatSetup-latest.exe" > WeChatSetup/latest/WeChatSetup-latest.exe.sha256

    # clean runtime
    rm -rfv ${temp_path}/*
}


function main() {
    install_depends
    download_wechat

    now_sum256=`shasum -a 256 ${temp_path}/WeChatSetup.exe | awk '{print $1}'`
    local latest_sum256=`cat ${latest_path}/WeChatSetup-latest.exe.sha256 | awk '{print $1}'`

    if [ "$now_sum256" = "$latest_sum256" ]; then
        >&2 echo -e "\n\033[1;32mThis is the newest Version! Clean runtime and exit...\033[0m\n"
        rm -rfv ${temp_path}/*
        exit 0
    fi
    ## if not the newest
    extract_version
    prepare_commit

    git add . && git commit -m "Add new dest version: $dest_version" && git push origin master
}

main

