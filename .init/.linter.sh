#!/bin/bash
cd /home/kavia/workspace/code-generation/india-airport-passenger-experience-platform-1591-1606/frontend_flight_management
npm run build
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
   exit 1
fi

