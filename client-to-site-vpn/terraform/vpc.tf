/*
VPC
*/

resource "aws_vpc" "vpn-demo" {
    cidr_block = "${var.vpc_ip_range}"
    tags {
        Name = "${var.environment}"
    }
}

/*
Internet Gateway
*/

resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.vpn-demo.id}"
    tags {
        Name = "IGW"
    }
}

