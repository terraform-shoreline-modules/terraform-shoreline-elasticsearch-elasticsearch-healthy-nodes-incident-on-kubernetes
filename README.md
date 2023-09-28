
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Elasticsearch Healthy Nodes Incident on Kubernetes
---

This incident type indicates an issue related to Elasticsearch nodes. Specifically, it indicates that one or more nodes in the Elasticsearch cluster are not healthy, which could cause performance issues or data loss. The incident may be triggered automatically by monitoring software or manually by a team member. It typically requires immediate attention to resolve the underlying issue and restore Elasticsearch nodes to a healthy state.

### Parameters
```shell
export POD_NAME="PLACEHOLDER"

export ELASTICSEARCH_NAMESPACE="PLACEHOLDER"

export THRESHOLD="PLACEHOLDER"

export ELASTICSEARCH_CONTAINER_NAME="PLACEHOLDER"

export ELASTICSEARCH_POD_LABEL="PLACEHOLDER"

export REPLICA_COUNT="PLACEHOLDER"

export DEPLOYMENT_NAME="PLACEHOLDER"
```

## Debug

### 1. Get the list of Elasticsearch cluster pods
```shell
kubectl get pods -n ${ELASTICSEARCH_NAMESPACE} -l ${ELASTICSEARCH_POD_LABEL}
```

### 2. Check the status of the Elasticsearch cluster pods
```shell
kubectl describe pods -n ${ELASTICSEARCH_NAMESPACE} ${POD_NAME}
```

### 3. Check the Elasticsearch cluster health status
```shell
kubectl exec -n ${ELASTICSEARCH_NAMESPACE} ${POD_NAME} -- curl -X GET "http://localhost:9200/_cluster/health?pretty"
```

### 4. Check the Elasticsearch cluster node status
```shell
kubectl exec -n ${ELASTICSEARCH_NAMESPACE} ${POD_NAME} -- curl -X GET "http://localhost:9200/_cat/nodes?v"
```

### Elasticsearch cluster is experiencing high CPU or memory usage.
```shell


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


```

### One or more Elasticsearch nodes are down or unresponsive.
```shell


#!/bin/bash



# Set variables

NAMESPACE=${ELASTICSEARCH_NAMESPACE}

ELASTICSEARCH_POD_LABEL=${ELASTICSEARCH_POD_LABEL}

ELASTICSEARCH_CONTAINER_NAME=${ELASTICSEARCH_CONTAINER_NAME}



# Check if Elasticsearch pods are running

if kubectl get pods -n $NAMESPACE -l $ELASTICSEARCH_POD_LABEL | grep Running >/dev/null; then

    echo "All Elasticsearch pods are running."

else

    echo "One or more Elasticsearch pods are not running:"

    kubectl get pods -n $NAMESPACE -l $ELASTICSEARCH_POD_LABEL | grep -v Running

fi



# Check if Elasticsearch nodes are responsive

for POD in $(kubectl get pods -n $NAMESPACE -l $ELASTICSEARCH_POD_LABEL | grep Running | cut -f1 -d' '); do

    if kubectl exec -n $NAMESPACE $POD -c $ELASTICSEARCH_CONTAINER_NAME -- curl -s http://localhost:9200/_cluster/health | grep -q '\"status\":\"green\"'; then

        echo "$POD is responding."

    else

        echo "$POD is not responding:"

        kubectl logs -n $NAMESPACE $POD -c $ELASTICSEARCH_CONTAINER_NAME

    fi

done


```

## Repair

### If there is a missing data node in the Elasticsearch cluster, add a new node or replace the missing one.
```shell
bash

#!/bin/bash



# Define the name of the Elasticsearch deployment and the number of replicas

deployment_name=${DEPLOYMENT_NAME}

replica_count=${REPLICA_COUNT}



# Get the current number of replicas

current_replicas=$(kubectl get deployment $deployment_name -o=jsonpath="{.spec.replicas}")



# If the current number of replicas is less than the desired replica count, scale up the deployment

if [ "$current_replicas" -lt "$replica_count" ]; then

    kubectl scale deployment $deployment_name --replicas=$replica_count

fi


```