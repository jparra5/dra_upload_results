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
#   $1  Log file location
#   $2  Environment
#   $3  Application Name
#   $4  Artifact
#   $5  Stage
#
function dra_commands {
    echo -e "${no_color}"
    node_modules_dir=`npm root`

    dra_grunt_command="grunt --gruntfile=$node_modules_dir/grunt-idra3/idra.js"
    dra_grunt_command="$dra_grunt_command -testResult=\"$DRA_CURRENT_DIR/$1\""
    dra_grunt_command="$dra_grunt_command -env=\"$2\""
    dra_grunt_command="$dra_grunt_command -runtime=\"$3\""
    dra_grunt_command="$dra_grunt_command -stage=\"$5\""
    # TODO: re-enable when IDS exposes the correct url.
    #dra_grunt_command="$dra_grunt_command -drilldownUrl=\"$IDS_URL/$PIPELINE_ID/$PIPELINE_STAGE_ID/executions/$PIPELINE_INITIAL_STAGE_EXECUTION_ID\""

    debugme echo -e "dra_grunt_command with tool, log, env, & stage: \n\t$dra_grunt_command"

    if [ -n "$4" ] && [ "$4" != " " ]; then

        debugme echo -e "\tartifact: '$4' is defined and not empty"
        dra_grunt_command="$dra_grunt_command -artifact=\"$4\""
        debugme echo -e "\tdra_grunt_command: \n\t\t$dra_grunt_command"

    else
        debugme echo -e "\tartifact: '$4' is not defined or is empty"
        debugme echo -e "${no_color}"
    fi


    debugme echo -e "FINAL dra_grunt_command: $dra_grunt_command"
    debugme echo -e "${no_color}"


    eval "$dra_grunt_command --no-color"
    GRUNT_RESULT=$?

    debugme echo "GRUNT_RESULT: $GRUNT_RESULT"

    if [ $GRUNT_RESULT -ne 0 ]; then
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

export DRA_CURRENT_DIR=`pwd`





installDRADependencies

custom_cmd


echo -e "${no_color}"
debugme echo "DRA_LOG_FILE: ${DRA_LOG_FILE}"
debugme echo "DRA_WORKING_DIRECTORY: ${DRA_WORKING_DIRECTORY}"
debugme echo "DRA_ENVIRONMENT: ${DRA_ENVIRONMENT}"
debugme echo "DRA_APPLICATION_NAME: ${DRA_APPLICATION_NAME}"
debugme echo "DRA_LIFE_CYCLE_STAGE_SELECT: ${DRA_LIFE_CYCLE_STAGE_SELECT}"

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

        for file in ${DRA_LOG_FILE}
        do
            filename=$(basename "$file")
            extension="${filename##*.}"
            filename="${filename%.*}"

            dra_commands "$file" "${DRA_ENVIRONMENT}" "${DRA_APPLICATION_NAME}" "$filename.$extension" "${DRA_LIFE_CYCLE_STAGE_SELECT}"
        done

    else
        echo -e "${no_color}"
        echo -e "${red}Location must be declared."
        echo -e "${no_color}"
    fi


    if [ -n "${DRA_ADDITIONAL_LOG_FILE}" ] && [ "${DRA_ADDITIONAL_LOG_FILE}" != " " ] && \
        [ -n "${DRA_ADDITIONAL_LIFE_CYCLE_STAGE_SELECT}" ] && [ "${DRA_ADDITIONAL_LIFE_CYCLE_STAGE_SELECT}" != "none" ]; then

        for file in ${DRA_ADDITIONAL_LOG_FILE}
        do
            filename=$(basename "$file")
            extension="${filename##*.}"
            filename="${filename%.*}"

            dra_commands "$file" "${DRA_ENVIRONMENT}" "${DRA_APPLICATION_NAME}" "$filename.$extension" "${DRA_ADDITIONAL_LIFE_CYCLE_STAGE_SELECT}"
        done

    else
        echo -e "${no_color}"
        echo -e "For the Additional upload to work, you must enter a Location and a Type of Metric."
        echo -e "${no_color}"
    fi
else
    echo -e "${no_color}"
    echo -e "${red}Environment Name and Application Name must be declared."
    echo -e "${no_color}"
fi
