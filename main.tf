provider "aws" {
  region = "us-east-1"
}

#Crea nuevo VPC llamado test_vpc
resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "test_vpc"
  }
}
#crea subnet privada
resource "aws_subnet" "my_subnet1_priv" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "my_subnet1_priv"
  }
}
#crea subnet publica
resource "aws_subnet" "my_subnet2_pub" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "my_subnet2_pub"
  }
}

#crea elastic ip
resource "aws_eip" "eip" {
  vpc = true
}

#crea internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "internet_gateway"
  }
}

#crea Nat gateway y lo asocia la pub
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.my_subnet2_pub.id

  tags = {
    Name = "nat_gateway"
  }
}

#crea tablas de ruteo para ig y red publica
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}
#crea tablas de ruteo para el nat y la red privada (anteriormente asociada a la publica)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private_rt"
  }
}
#asocia las tablas anteriormente mencionadas
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.my_subnet2_pub.id
  route_table_id = aws_route_table.public_rt.id
}
#asocia las tablas anteriormente mencionadas
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.my_subnet1_priv.id
  route_table_id = aws_route_table.private_rt.id
}

#hasta este punto testeado, funciona al 100%

#Agregando recursos

#se agregan 2 instancias 1 a cada subnet

resource "aws_instance" "istea_ec2_public" {

    ami = "ami-04e5276ebb8451442"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.my_subnet2_pub.id

    tags = {
        Name = "instancia_public"
    }

}

resource "aws_instance" "istea_ec2_private" {

    ami = "ami-04e5276ebb8451442"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.my_subnet1_priv.id

    tags = {
        Name = "instancia_private"
    }

}

#bucket publico abierto 

# Crear bucket público sin ACL
resource "aws_s3_bucket" "publicbucketistea" {
  bucket = "publicbucketistea"

  tags = {
    Name = "publicbucketistea"
  }
}

# Política para hacer el bucket público
resource "aws_s3_bucket_policy" "publicbucket_policy" {
  bucket = aws_s3_bucket.publicbucketistea.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PrivateBucketAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::publicbucketistea/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceVpc": "${aws_vpc.test_vpc.id}"
        },
        "IpAddress": {
          "aws:SourceIp": "${aws_instance.istea_ec2_public.private_ip}"
        }
      }
    },
    {
      "Sid": "AllowAdminFullAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::767397721255:user/andres.sasso@istea.com.ar"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::publicbucketistea",
        "arn:aws:s3:::publicbucketistea/*"
      ]
    }
  ]
}
POLICY
}

#creacion y politica para el bucket privado 
resource "aws_s3_bucket" "privatebucketistea" {
  bucket = "privatebucketistea"

  acl = "private"

  tags = {
    Name = "privatebucketistea"
  }
}

resource "aws_s3_bucket_policy" "privatebucket_policy" {
  bucket = aws_s3_bucket.privatebucketistea.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PrivateBucketAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::privatebucketistea/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceVpc": "${aws_vpc.test_vpc.id}"
        },
        "IpAddress": {
          "aws:SourceIp": "${aws_instance.istea_ec2_private.private_ip}"
        }
      }
    },
    {
      "Sid": "AllowAdminFullAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::767397721255:user/andres.sasso@istea.com.ar"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::privatebucketistea",
        "arn:aws:s3:::privatebucketistea/*"
      ]
    }
  ]
}
POLICY
}

#hasta aca funciona

#creacion de ecr elastic container registry
resource "aws_ecr_repository" "istea_containers_test" {
  name = "istea-containers"
  
  image_tag_mutability = "IMMUTABLE"
  
  encryption_configuration {
    encryption_type = "AES256"
  }
  
  image_scanning_configuration {
    scan_on_push = true
  }
}
#politicas de ecr elastic container registry
resource "aws_ecr_repository_policy" "istea_containers_policy" {
  repository = aws_ecr_repository.istea_containers_test.name
  
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
          "AWS": "arn:aws:iam::767397721255:user/andres.sasso@istea.com.ar"
        },
        "Action": [
          "ecr:*"
        ]
      }
    ]
  })
}