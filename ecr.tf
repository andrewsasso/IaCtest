resource "aws_ecr_repository" "istea_containers_tp1test" {
  name = "istea-containers"
  
  image_tag_mutability = "IMMUTABLE"
  
  encryption_configuration {
    encryption_type = "AES256"
  }
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "istea_containers_policy" {
  repository = aws_ecr_repository.istea_containers_tp1test.name
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowPull",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
      },
      {
        "Sid": "AllowAll",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::account-id:user/admin-user"
        },
        "Action": [
          "ecr:*"
        ]
      }
    ]
  })
}