
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
