# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "frontend_5xx_errors" {
  # ... Frontend 5XX errors alarm configuration
}

resource "aws_cloudwatch_metric_alarm" "service_a_latency" {
  # ... Service A latency alarm configuration
}

resource "aws_cloudwatch_metric_alarm" "service_b_sqs_age" {
  # ... Service B SQS message age alarm configuration
}
