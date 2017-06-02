
/*
VPC Subnets
*/

resource "aws_subnet" "Public_1a" {
  vpc_id = "${aws_vpc.vpn-demo.id}"
  cidr_block = "${var.public_1a_ip_range}"
  availability_zone = "${var.availablity_zone_a}"
  tags {
        Name = "Public_1a"
    }
}

resource "aws_subnet" "Public_1b" {
  vpc_id = "${aws_vpc.vpn-demo.id}"
  cidr_block = "${var.public_1b_ip_range}"
  availability_zone = "${var.availablity_zone_b}"
  tags {
        Name = "Public_1b"
    }
}

resource "aws_subnet" "Private_1a" {
  vpc_id = "${aws_vpc.vpn-demo.id}"
  cidr_block = "${var.private_1a_ip_range}"
  availability_zone = "${var.availablity_zone_a}"
  tags {
    Name = "Private_1a"
  }
}

resource "aws_subnet" "Private_1b" {
  vpc_id = "${aws_vpc.vpn-demo.id}"
  cidr_block = "${var.private_1b_ip_range}"
  availability_zone = "${var.availablity_zone_b}"
  tags {
    Name = "Private_1b"
  }
}
