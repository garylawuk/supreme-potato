resource "aws_instance" "example" {
  ami                          = "${var.UBU_ami}"
  instance_type                = "t2.micro"
  subnet_id                    = "${aws_subnet.Private_1a.id}"
  private_ip                   = "${var.VPNa_ip_public}"
  key_name                     = "${var.key_name}"
  source_dest_check            = "False"
  associate_public_ip_address  = "True"
  vpc_security_group_ids       = [ "${aws_security_group.sg_ext_vpn.id}" ]
  tags {
  	Name                         = "${var.environment}-server"
  }
}
