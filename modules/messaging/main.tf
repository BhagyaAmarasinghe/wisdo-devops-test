# SQS Queue for Service B
resource "aws_sqs_queue" "service_b_queue" {
  # ... SQS queue configuration
}

resource "aws_sqs_queue" "service_b_dlq" {
  # ... SQS dead-letter queue configuration
}
