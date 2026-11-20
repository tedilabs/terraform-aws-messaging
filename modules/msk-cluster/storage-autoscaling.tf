###################################################
# Storage Autoscaling for MSK Cluster
###################################################

resource "aws_appautoscaling_target" "storage" {
  count = var.broker_storage.autoscaling.enabled ? 1 : 0

  region = var.region

  service_namespace  = "kafka"
  resource_id        = aws_msk_cluster.this.arn
  scalable_dimension = "kafka:broker-storage:VolumeSize"

  # MSK grows the storage only, so the minimum capacity has no effect.
  min_capacity = 1
  max_capacity = var.broker_storage.autoscaling.max_volume_size

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}

resource "aws_appautoscaling_policy" "storage" {
  count = var.broker_storage.autoscaling.enabled ? 1 : 0

  region = var.region

  name               = "${var.name}-storage-autoscaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.storage[0].service_namespace
  resource_id        = aws_appautoscaling_target.storage[0].resource_id
  scalable_dimension = aws_appautoscaling_target.storage[0].scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "KafkaBrokerStorageUtilization"
    }

    target_value = var.broker_storage.autoscaling.target_utilization
    # MSK does not support decreasing the size of broker storage.
    disable_scale_in = true
  }
}
