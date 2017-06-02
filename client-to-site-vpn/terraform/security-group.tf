# security group set up

resource "aws_security_group" "sg_ext_vpn" {
  name = "sg_ext_vpn"
  description = "VPN public network security group"
  vpc_id = "${aws_vpc.vpn-demo.id}"

  tags {
    Name = "${var.environment}-sg_ext_vpn"
  }

  ingress {
    from_port = 500
    to_port = 500
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 500
    to_port = 500
    protocol = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 4500
    to_port = 4501
    protocol = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.ip_management_access}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
