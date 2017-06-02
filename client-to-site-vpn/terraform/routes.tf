# Routing
/*
Create Routing table External with a route to the Internet Gateway
*/

resource "aws_route_table" "vpn-demo_External" {
    vpc_id = "${aws_vpc.vpn-demo.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.IGW.id}"
    }

    tags {
        Name = "vpn-demo_External"
    }
}

/*
Replace default routing table with routing table created above
*/

resource "aws_main_route_table_association" "vpn-demo_Routing_Table_Association" {
    vpc_id = "${aws_vpc.vpn-demo.id}"
    route_table_id = "${aws_route_table.vpn-demo_External.id}"
}

/*
Create Routing table association between vpn-demo_External and subnet Public_1a
*/

resource "aws_route_table_association" "External_1a" {
    subnet_id = "${aws_subnet.Public_1a.id}"
    route_table_id = "${aws_route_table.vpn-demo_External.id}"
}

/*
Create Routing table association between vpn-demo_External and subnet Public_1b
*/

resource "aws_route_table_association" "External_1b" {
    subnet_id = "${aws_subnet.Public_1b.id}"
    route_table_id = "${aws_route_table.vpn-demo_External.id}"
}
