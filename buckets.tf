resource "aws_s3_bucket" "bucket_public" {
    bucket = "publicbucketistea"
    acl    = "public-read"
}

resource "aws_s3_bucket_policy" "bucket_public_policy" {
    bucket = aws_s3_bucket.bucket_public.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect   = "Allow"
                Principal = "*"
                Action    = "s3:GetObject"
                Resource  = "${aws_s3_bucket.bucket_public.arn}/*"
            }
        ]
    })
}

resource "aws_s3_bucket" "bucket_private" {
  bucket = "privatebucketistea"
}

resource "aws_s3_bucket_policy" "bucket_private_policy" {
  bucket = aws_s3_bucket.bucket_private.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "${aws_s3_bucket.bucket_private.arn}/*"
        Condition = {
          StringNotEquals = {
            "aws:sourceVpc" = aws_subnet.my_subnet1_priv.vpc_id
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "${aws_s3_bucket.bucket_private.arn}/*"
        Condition = {
          StringEquals = {
            "aws:sourceVpc" = aws_subnet.my_subnet1_priv.vpc_id
          }
        }
      }
    ]
  })
}