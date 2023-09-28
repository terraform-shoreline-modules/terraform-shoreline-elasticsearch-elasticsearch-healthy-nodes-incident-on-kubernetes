

#!/bin/bash



# Set variables

NAMESPACE=${ELASTICSEARCH_NAMESPACE}

POD_NAME=${POD_NAME}

CONTAINER_NAME=${ELASTICSEARCH_CONTAINER_NAME}

THRESHOLD=${THRESHOLD}



# Get CPU and memory usage for the Elasticsearch container

USAGE=$(kubectl exec -n $NAMESPACE $POD_NAME -c $CONTAINER_NAME -- sh -c "ps -eo pid,pcpu,pmem | grep -E 'PID|$ELASTICSEARCH_SERVICE_NAME' | grep -v grep" | awk '{print $2,$3}')

CPU=$(echo $USAGE | awk '{print $1}')

MEMORY=$(echo $USAGE | awk '{print $2}')



# Check if CPU or memory usage is above threshold

if (( $(echo "$CPU > $THRESHOLD" | bc -l) )); then

    echo "CPU usage is above threshold."

    echo "Usage: $CPU%"

fi



if (( $(echo "$MEMORY > $THRESHOLD" | bc -l) )); then

    echo "Memory usage is above threshold."

    echo "Usage: $MEMORY%"

fi