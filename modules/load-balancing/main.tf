# Application Load Balancer
resource "aws_lb" "main" {
  # ... ALB configuration
}

resource "aws_lb_target_group" "frontend" {
  # ... Frontend target group configuration
}

resource "aws_lb_listener" "https" {
  # ... HTTPS listener configuration
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  # ... CloudFront distribution configuration
}
