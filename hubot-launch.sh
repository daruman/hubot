#!/bin/bash

# $ sh launch-hubot.sh {config name}
# config file path: ./conf/

set -e

source ./config/"$1"

npm install

export PATH="node_modules/.bin:node_modules/hubot/node_modules/.bin:$PATH"
export HUBOT_SLACK_TOKEN="$SLACK_API_HUBOT_TOKEN"
export PORT=$USE_PORT

forever --minUptime 3000 --spinSleepTime 3000 start -c coffee node_modules/.bin/hubot -a slack  "$BACKLOG_URL" "$WEBHOOK_KEYWORD"
