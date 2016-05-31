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

set +e
set +x 




#
# Build Grunt-Idra call
#
#   $1  Tool
#   $2  Log file location
#   $3  Environment
#   $4  Application Name
#   $5  Artifact
#   $6  Stage
#
function dra_commands {
    echo -e "${no_color}"
    node_modules_dir=`npm root`
    dra_grunt_command="grunt --gruntfile=$node_modules_dir/grunt-idra3/idra.js -tool=$1"
    dra_grunt_command="$dra_grunt_command -testResult=\"$2\""
    dra_grunt_command="$dra_grunt_command -env=\"$3\""
    dra_grunt_command="$dra_grunt_command -runtime=\"$4\""
    dra_grunt_command="$dra_grunt_command -stage=$6"

    debugme echo -e "dra_grunt_command with tool, log, env, & stage: \n\t$dra_grunt_command"

    if [ -n "$5" ] && [ "$5" != " " ]; then

        debugme echo -e "\tartifact: '$5' is defined and not empty"
        dra_grunt_command="$dra_grunt_command -artifact=\"$5\""
        debugme echo -e "\tdra_grunt_command: \n\t\t$dra_grunt_command"

    else
        debugme echo -e "\tartifact: '$5' is not defined or is empty"
        debugme echo -e "${no_color}"
    fi


    debugme echo -e "FINAL dra_grunt_command: $dra_grunt_command"
    debugme echo -e "${no_color}"


    eval "$dra_grunt_command --no-color"
    GRUNT_RESULT=$?

    debugme echo "GRUNT_RESULT: $GRUNT_RESULT"

    if [ $GRUNT_RESULT -ne 0 ]; then
        echo -e "${no_color}"
        sudo apt-get update &>/dev/null
        sudo apt-get -y install traceroute &>/dev/null
        DLMS_ROUTE=`echo "${DLMS_SERVER}" | sed -e 's/^http:\/\///g' -e 's/^https:\/\///g'`
        traceroute "$DLMS_ROUTE"
        echo -e "${no_color}"

        exit 1
    fi
    
    echo -e "${no_color}"
}










callOpenToolchainAPI

printInitialDRAMessage





if [ -n "${DRA_WORKING_DIRECTORY}" ] && [ "${DRA_WORKING_DIRECTORY}" != "" ]; then
    debugme echo "Changed directory to: ${DRA_WORKING_DIRECTORY}"
    cd "${DRA_WORKING_DIRECTORY}"
    CHANGE_WORKING_DIR_RESULT=$?

    debugme echo "CHANGE_WORKING_DIR_RESULT: $CHANGE_WORKING_DIR_RESULT"

    if [ $CHANGE_WORKING_DIR_RESULT -ne 0 ]; then
        exit 1
    fi
fi





installDRADependencies

custom_cmd


echo -e "${no_color}"
debugme echo "DRA_FORMAT_SELECT: ${DRA_FORMAT_SELECT}"
debugme echo "DRA_LOG_FILE: ${DRA_LOG_FILE}"
debugme echo "DRA_WORKING_DIRECTORY: ${DRA_WORKING_DIRECTORY}"
debugme echo "DRA_ENVIRONMENT: ${DRA_ENVIRONMENT}"
debugme echo "DRA_APPLICATION_NAME: ${DRA_APPLICATION_NAME}"
debugme echo "DRA_LIFE_CYCLE_STAGE_SELECT: ${DRA_LIFE_CYCLE_STAGE_SELECT}"

debugme echo "DRA_ADDITIONAL_FORMAT_SELECT: ${DRA_ADDITIONAL_FORMAT_SELECT}"
debugme echo "DRA_ADDITIONAL_LOG_FILE: ${DRA_ADDITIONAL_LOG_FILE}"
debugme echo "DRA_ADDITIONAL_LIFE_CYCLE_STAGE_SELECT: ${DRA_ADDITIONAL_LIFE_CYCLE_STAGE_SELECT}"

debugme echo "CF_CONTROLLER: ${CF_CONTROLLER}"
debugme echo "DRA_SERVER: ${DRA_SERVER}"
debugme echo "DLMS_SERVER: ${DLMS_SERVER}"
debugme echo "CF_ORGANIZATION_ID: $CF_ORGANIZATION_ID"
debugme echo "PIPELINE_INITIAL_STAGE_EXECUTION_ID: $PIPELINE_INITIAL_STAGE_EXECUTION_ID"
debugme echo -e "${no_color}"


if [ -n "${DRA_ENVIRONMENT}" ] && [ "${DRA_ENVIRONMENT}" != " " ] && \
    [ -n "${DRA_APPLICATION_NAME}" ] && [ "${DRA_APPLICATION_NAME}" != " " ]; then

    if [ -n "${DRA_LOG_FILE}" ] && [ "${DRA_LOG_FILE}" != " " ]; then

        filename=$(basename "${DRA_LOG_FILE}")
        extension="${filename##*.}"
        filename="${filename%.*}"

        dra_commands "${DRA_FORMAT_SELECT}" "${DRA_LOG_FILE}" "${DRA_ENVIRONMENT}" "${DRA_APPLICATION_NAME}" "$filename.$extension" "${DRA_LIFE_CYCLE_STAGE_SELECT}"

    else
        echo -e "${no_color}"
        echo -e "${red}Location must be declared."
        echo -e "${no_color}"
    fi


    if [ -n "${DRA_ADDITIONAL_LOG_FILE}" ] && [ "${DRA_ADDITIONAL_LOG_FILE}" != " " ] && \
        [ -n "${DRA_ADDITIONAL_FORMAT_SELECT}" ] && [ "${DRA_ADDITIONAL_FORMAT_SELECT}" != "none" ] && \
        [ -n "${DRA_ADDITIONAL_LIFE_CYCLE_STAGE_SELECT}" ] && [ "${DRA_ADDITIONAL_LIFE_CYCLE_STAGE_SELECT}" != "none" ]; then

        filename=$(basename "${DRA_ADDITIONAL_LOG_FILE}")
        extension="${filename##*.}"
        filename="${filename%.*}"

        dra_commands "${DRA_ADDITIONAL_FORMAT_SELECT}" "${DRA_ADDITIONAL_LOG_FILE}" "${DRA_ENVIRONMENT}" "${DRA_APPLICATION_NAME}" "$filename.$extension" "${DRA_ADDITIONAL_LIFE_CYCLE_STAGE_SELECT}"

    else
        echo -e "${no_color}"
        echo -e "For the Additional upload to work, you must enter a Location, Format, and a Life Cycle Stage."
        echo -e "${no_color}"
    fi
else
    echo -e "${no_color}"
    echo -e "${red}Environment Name and Application Name must be declared."
    echo -e "${no_color}"
fi
