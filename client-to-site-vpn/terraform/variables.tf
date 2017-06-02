/*
Define Variables
*/

variable "vpc_ip_range" { default = "10.0.0.0/20" }
variable "private_1a_ip_range" { default = "10.0.0.0/24" }
variable "private_1b_ip_range" { default = "10.0.1.0/24" }
variable "public_1a_ip_range" { default = "10.0.8.0/24" }
variable "public_1b_ip_range" { default = "10.0.9.0/24" }
variable "key_name" { default = "vpn-demo" }
variable "environment" { default = "vpn-demo-dev" }

/*
Set AWS Region
variable "aws_region" { default =  "eu-central-1" }
*/


/*
Set Availability Zones
*/

variable "availablity_zone_a" { default = "eu-central-1a" }
variable "availablity_zone_b" { default = "eu-central-1b" }
variable "availablity_zone_c" { default = "eu-central-1c" }

/*
Set Ubuntu AMI values
*/

variable "UBU_ami" { default = "ami-004abc6f" }
variable "UBU_ami_blue" { default = "ami-004abc6f" }
variable "UBU_ami_green" { default = "ami-f95ef58a" }

/*
IP Addresses for instances
*/

variable "VPNa_ip_public" { default = "10.0.0.100" }
variable "VPNa_ip_private" { default = "10.0.8.100" }

/*
IP Address for management access
*/

variable "ip_management_access" { default = "193.240.153.130" }


