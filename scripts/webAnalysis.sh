#!/bin/bash
###############################################
###           Available URL Test            ###
###############################################
#
# ---------------------------------------------
# Script for get kubeconfig
# ---------------------------------------------
#
# Version 0.1: Initial version
#
###############################################
#
# History:
#
# v0.1 2022-10-25, Bruno Correia:
#       - Initial version
#
###############################################

declare -r BOLD="\033[1m"
declare -r RED="\033[1;31m"
declare -r GREEN="\033[1;32m"
declare -r YELLOW="\033[1;33m"
declare -r NC="\033[0m"
declare -r NOW=$(date +"%Y%m%d%H%M%S")

function usage() {
    cat <<EOF

    Usage: ${0} [OPTIONS]

    Options:

        -u, --url               URL for test
        -r, --requests          Total requests
        -i, --interval          Interval between each request in seconds - Default value: 2 seconds
        -o, --report-file       [OPTIONAL] Output path for save csv report - Default value: "./AAAAMMDDhhmmss_availableReport.csv"

        -H, --help          Show this help
        -V, --version       Show this program version

EOF
}

function extract-version() {
    grep '^# Version ' "${0}" | tail -1 | cut -d : -f 1 | tr -d \#
}

function log() {
    echo -e "${1}"
}

function check-permissions() {
    local dir="${1}"
    if [ -d "${dir}" ]; then
        if ! test -w "${dir}"; then
            log "\n${RED}ERROR:${NC} Check your permissions on directory \"${dir}\"\n"
            exit 1
        fi
    else
        touch "${dir}" &> /dev/null
        statusCode="${?}"
        if [ ${statusCode} -ne 0 ]; then
            log "${RED}ERROR:${NC} is not possible for write on \"${dir}\", check your permissions"
            exit ${statusCode}
        fi
    fi
}

function parameter-check() {
    local parameter="${1}"
    local value="${2}"
    if [ -z ${value} ]; then
        log "\n${RED}ERROR:${NC} Missing value for ${parameter} parameter\n"
        usage
        exit 1 
    fi
}

function execution(){
    local url=$1
    local totalRequests=$2
    local interval=$3
    local logFile=$4

    > $logFile
    echo "time;location;status" >> $logFile

    local request=0
    while [ $request -lt $totalRequests ]; do
        date=$(date '+%Y-%m-%d %H:%M:%S')
        response=$(curl --connect-timeout 1 --max-time 1 $url -s)
        cmdResponse=$?

        # Return's code:
        # 0 - Success
        # 1 - Failed
        # 4 - Invalid
        validateResponse=$(jq -er '.' >/dev/null 2>&1 <<< "$response" ; echo $?)

        log "·····························"
        log "${BOLD}Request: $((request+1))${NC}"
        log "JSON Validate return code: ${validateResponse}" 
        log "GET Response:"
        if [[ ( $cmdResponse -eq 0 || ! -z $response ) && $validateResponse -eq 0 ]]; then
            log "$response"
            location=$(jq -er '.location' <<< "$response")
            log "${date};${location};1"
            echo "${date};${location};1" >> $logFile
        else
            log "${date};none;0"
            echo "${date};none;0" >> $logFile
        fi

        let request=$request+1
        sleep $interval
    done

}

function main() {
    local url
    local totalRequests
    local interval
    local logFile

    while test -n "${1}"; do
        case "${1}" in
            -u|--url)
                parameter-check "-u" "${2}"
                url="${2}"
                ;;
            -r|--requests)
                parameter-check "-r" "${2}"
                totalRequests="${2}"
                ;;
            -i|--interval)
                parameter-check "-i" "${2}"
                interval="${2}"
                ;;
            -o|--report-file)
                parameter-check "-r" "${2}"
                logFile="$(echo ${2} | sed 's/\/\//\//g')"
                check-permissions "${logFile}"
                ;;
            -H|--help)
                usage
                exit 0
                ;;
            -V|--version)
                extract-version
                exit 0
                ;;
            *)
                usage
                exit 1
                ;;
        esac
        shift;shift
    done
    
    if [ -z ${url} ]; then
        log "\n${RED}ERROR:${NC} Missing -u parameter\n"
        usage
        exit 1
    fi

    if [ -z ${totalRequests} ]; then
        log "\n${RED}ERROR:${NC} Missing -r parameter\n"
        usage
        exit 1
    fi 
    
    if [ -z ${interval} ]; then
        interval=2
    fi

    if [ -z ${logFile} ]; then
        logFile="./${NOW}_availableReport.csv"
    fi
    
    execution "${url}" "${totalRequests}" "${interval}" "${logFile}"
}

main ${@}