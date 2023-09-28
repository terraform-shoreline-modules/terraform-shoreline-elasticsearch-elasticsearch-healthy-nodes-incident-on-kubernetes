resource "shoreline_notebook" "elasticsearch_healthy_nodes_incident_on_kubernetes" {
  name       = "elasticsearch_healthy_nodes_incident_on_kubernetes"
  data       = file("${path.module}/data/elasticsearch_healthy_nodes_incident_on_kubernetes.json")
  depends_on = [shoreline_action.invoke_elasticsearch_threshold_script,shoreline_action.invoke_elasticsearch_check,shoreline_action.invoke_scale_up_deployment]
}

resource "shoreline_file" "elasticsearch_threshold_script" {
  name             = "elasticsearch_threshold_script"
  input_file       = "${path.module}/data/elasticsearch_threshold_script.sh"
  md5              = filemd5("${path.module}/data/elasticsearch_threshold_script.sh")
  description      = "Elasticsearch cluster is experiencing high CPU or memory usage."
  destination_path = "/agent/scripts/elasticsearch_threshold_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "elasticsearch_check" {
  name             = "elasticsearch_check"
  input_file       = "${path.module}/data/elasticsearch_check.sh"
  md5              = filemd5("${path.module}/data/elasticsearch_check.sh")
  description      = "One or more Elasticsearch nodes are down or unresponsive."
  destination_path = "/agent/scripts/elasticsearch_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "scale_up_deployment" {
  name             = "scale_up_deployment"
  input_file       = "${path.module}/data/scale_up_deployment.sh"
  md5              = filemd5("${path.module}/data/scale_up_deployment.sh")
  description      = "If there is a missing data node in the Elasticsearch cluster, add a new node or replace the missing one."
  destination_path = "/agent/scripts/scale_up_deployment.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_elasticsearch_threshold_script" {
  name        = "invoke_elasticsearch_threshold_script"
  description = "Elasticsearch cluster is experiencing high CPU or memory usage."
  command     = "`chmod +x /agent/scripts/elasticsearch_threshold_script.sh && /agent/scripts/elasticsearch_threshold_script.sh`"
  params      = ["ELASTICSEARCH_CONTAINER_NAME","POD_NAME","THRESHOLD","ELASTICSEARCH_NAMESPACE","NAMESPACE"]
  file_deps   = ["elasticsearch_threshold_script"]
  enabled     = true
  depends_on  = [shoreline_file.elasticsearch_threshold_script]
}

resource "shoreline_action" "invoke_elasticsearch_check" {
  name        = "invoke_elasticsearch_check"
  description = "One or more Elasticsearch nodes are down or unresponsive."
  command     = "`chmod +x /agent/scripts/elasticsearch_check.sh && /agent/scripts/elasticsearch_check.sh`"
  params      = ["ELASTICSEARCH_POD_LABEL","ELASTICSEARCH_CONTAINER_NAME","ELASTICSEARCH_NAMESPACE","NAMESPACE"]
  file_deps   = ["elasticsearch_check"]
  enabled     = true
  depends_on  = [shoreline_file.elasticsearch_check]
}

resource "shoreline_action" "invoke_scale_up_deployment" {
  name        = "invoke_scale_up_deployment"
  description = "If there is a missing data node in the Elasticsearch cluster, add a new node or replace the missing one."
  command     = "`chmod +x /agent/scripts/scale_up_deployment.sh && /agent/scripts/scale_up_deployment.sh`"
  params      = ["DEPLOYMENT_NAME","REPLICA_COUNT"]
  file_deps   = ["scale_up_deployment"]
  enabled     = true
  depends_on  = [shoreline_file.scale_up_deployment]
}

