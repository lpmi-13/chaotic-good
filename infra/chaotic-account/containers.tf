# we need task definitions, a fargate cluster, and a fargate service
# ...debatable whether this repo should be cross-account...
resource "aws_ecr_repository" "chaotic-backend" {
  name                 = "chaotic-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
