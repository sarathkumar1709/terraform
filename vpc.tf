provider "aws" {
  region = "ap-south-1"
}
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "newvpc"
  }
}

resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "pubsub"
  }
}

resource "aws_subnet" "prisub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "prisub"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "pubrt"
  }
}

resource "aws_route_table_association" "pubassociation" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_route_table" "prirt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    }
  tags = {
    Name = "prirt"
  }
}

resource "aws_route_table_association" "priassociation" {
  subnet_id      = aws_subnet.prisub.id
  route_table_id = aws_route_table.prirt.id
}

resource "aws_security_group" "allow_all" {
  name        = "allowall"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "pub" {
  ami           = "ami-0bcf5425cdc1d8a85"
  instance_type = "t2.micro"
  subnet_id   = aws_subnet.pubsub.id
  key_name = "windowskey"
  vpc_security_group_ids  = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address = true
  tags = {
    Name = "pub"
  }
}
resource "aws_instance" "pri" {
  ami           = "ami-0bcf5425cdc1d8a85"
  instance_type = "t2.micro"
  subnet_id   = aws_subnet.prisub.id
  key_name = "windowskey"
  vpc_security_group_ids  = ["${aws_security_group.allow_all.id}"]
 tags = {
    Name = "pri"
  }
}