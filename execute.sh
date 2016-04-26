#!/bin/bash

#********************************************************************************
# Copyright 2014 IBM
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#********************************************************************************

#############
# Colors    #
#############
export green='\e[0;32m'
export red='\e[0;31m'
export label_color='\e[0;33m'
export no_color='\e[0m' # No Color

##################################################
# Simple function to only run command if DEBUG=1 # 
### ###############################################
debugme() {
  [[ $EXTENSION_DEBUG = 1 ]] && "$@" || :
}

set +e
set +x 




#
# Build Grunt-Idra call
#
#   $1  Tool
#   $2  Log file location
#   $3  Environment
#   $4  Microservice
#   $5  Module
#   $6  Stage
#
function dra_commands {
    echo -e "${no_color}"
    dra_grunt_command=""
    
    if [ -n "$1" ] && [ "$1" != " " ]; then
    
        dra_grunt_command="grunt --gruntfile=node_modules/grunt-idra3/idra.js -tool=$1"
        dra_grunt_command="$dra_grunt_command -testResult=$2"
        dra_grunt_command="$dra_grunt_command -env=$3"
        dra_grunt_command="$dra_grunt_command -stage=$6"
        
        debugme echo -e "dra_grunt_command with tool, log, env, & stage: \t$dra_grunt_command"
        
        if [ -n "$4" ] && [ "$4" != " " ]; then
        
            debugme echo -e "\tMicroservice: '$4' is defined and not empty"
            dra_grunt_command="$dra_grunt_command -stage=$4"
            debugme echo -e "\t\tdra_grunt_command: $dra_grunt_command"
            
        else
            debugme echo -e "Life cycle stage: '$4' is not defined or is empty"
            debugme echo -e "${no_color}"
        fi
        
        if [ -n "$5" ] && [ "$5" != " " ]; then
        
            debugme echo -e "\tLife cycle stage: '$5' is defined and not empty"
            dra_grunt_command="$dra_grunt_command -stage=$5"
            debugme echo -e "\t\tdra_grunt_command: $dra_grunt_command"
            
        else
            debugme echo -e "Life cycle stage: '$5' is not defined or is empty"
            debugme echo -e "${no_color}"
        fi
        
        
        debugme echo -e "FINAL dra_grunt_command: $dra_grunt_command"
        debugme echo -e "${no_color}"
        
        
        eval "$dra_grunt_command --no-color"
        GRUNT_RESULT=$?
        
        debugme echo "GRUNT_RESULT: $GRUNT_RESULT"
        
        if [ $GRUNT_RESULT -ne 0 ] && [ "${DRA_ADVISORY_MODE}" == "false" ]; then
            exit 1
        fi
    else
        debugme echo "Event: '$1' is not defined or is empty"
    fi
    
    echo -e "${no_color}"
}





if [ -z "$TOOLCHAIN_TOKEN" ]; then
    export CF_TOKEN=$(sed -e 's/^.*"AccessToken":"\([^"]*\)".*$/\1/' ~/.cf/config.json)
else
    export CF_TOKEN=$TOOLCHAIN_TOKEN
fi


OUTPUT_FILE='draserver.txt'
${EXT_DIR}/dra-check.py ${PIPELINE_TOOLCHAIN_ID} "${CF_TOKEN}" "${IDS_PROJECT_NAME}" "${OUTPUT_FILE}"
RESULT=$?

#0 = DRA is present
#1 = DRA not present or there was an error with the http call (err msg will show)
#echo $RESULT

if [ $RESULT -eq 0 ]; then
    debugme echo "DRA is present";
    
    echo -e "${green}"
    echo "**********************************************************************"
    echo "Deployment Risk Analytics (DRA) is active."
    echo "**********************************************************************"
    echo -e "${no_color}"
    
    #
    # Retrieve variables from toolchain API
    #
    DRA_CHECK_OUTPUT=`cat ${OUTPUT_FILE}`
    IFS=$'\n' read -rd '' -a dradataarray <<< "$DRA_CHECK_OUTPUT"
    export CF_ORGANIZATION_ID=${dradataarray[0]}
    #export DRA_SERVER=${dradataarray[1]}
    rm ${OUTPUT_FILE}
    
    #
    # Hardcoded until brokers are updated (DRA) and created (DLMS)
    #
    #export DLMS_SERVER=http://devops-datastore.stage1.mybluemix.net
    #export DRA_SERVER=https://dra3.stage1.mybluemix.net
    
    npm install grunt-idra3

    
fi





npm install grunt
npm install grunt-cli




custom_cmd


echo -e "${no_color}"
debugme echo "DRA_FORMAT_SELECT: ${DRA_ADVISORY_MODE}"
debugme echo "DRA_LOG_FILE: ${DRA_TEST_TOOL_SELECT}"
debugme echo "DRA_ENVIRONMENT: ${DRA_TEST_LOG_FILE}"
debugme echo "DRA_MICROSERVICE: ${DRA_MINIMUM_SUCCESS_RATE}"
debugme echo "DRA_MODULE: ${DRA_CHECK_TEST_REGRESSION}"
debugme echo "DRA_LIFE_CYCLE_STAGE_SELECT: ${DRA_LIFE_CYCLE_STAGE_SELECT}"

debugme echo "DRA_SERVER: ${DRA_SERVER}"
debugme echo "CF_ORGANIZATION_ID: $CF_ORGANIZATION_ID"
debugme echo "PIPELINE_INITIAL_STAGE_EXECUTION_ID: $PIPELINE_INITIAL_STAGE_EXECUTION_ID"
debugme echo -e "${no_color}"




if [ -n "${DRA_LOG_FILE}" ] && [ "${DRA_LOG_FILE}" != " " ] && \
    [ -n "${DRA_ENVIRONMENT}" ] && [ "${DRA_ENVIRONMENT}" != " " ]; then

    if [ [ -n "${DRA_MICROSERVICE}" ] && [ "${DRA_MICROSERVICE}" != " " ] ] || \
        [ [ -n "${DRA_MODULE}" ] && [ "${DRA_MODULE}" != " " ] ]; then
    
        dra_commands "${DRA_FORMAT_SELECT}" "${DRA_LOG_FILE}" "${DRA_ENVIRONMENT}" "${DRA_MICROSERVICE}" "${DRA_MODULE}" "${DRA_LIFE_CYCLE_STAGE_SELECT}"
    
    else
        echo -e "${no_color}"
        echo -e "${red}Microservice and/or a Module must be declared."
        echo -e "${no_color}"
    fi
    
else
    echo -e "${no_color}"
    echo -e "${red}Location and an Environment Name must be declared."
    echo -e "${no_color}"
fi




