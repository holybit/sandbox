#!/bin/bash

java -jar /Users/heathercrotty/git/sandbox/lib/selenium-server-standalone-2.15.0.jar -role hub > sl_hub_server.log 2>&1 &
sleep 15
java -jar /Users/heathercrotty/git/sandbox/lib/selenium-server-standalone-2.15.0.jar -role webdriver -nodeConfig config.json -hub http://127.0.0.1:4444/grid/register > slNodes.log 2>&1 &
