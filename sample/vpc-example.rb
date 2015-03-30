require 'cfndsl'

CloudFormation {
  Description "Creates an AWS VPC with a couple of subnets."

  VPC(:VPC) {
    EnableDnsSupport true
    EnableDnsHostnames true
    CidrBlock "10.1.0.0/16"
    addTag("Name", "Test VPC")
  }

  InternetGateway(:InternetGateway) {
    addTag("Name", "Test VPC Gateway")
  }

  VPCGatewayAttachment(:GatewayToInternet) {
    VpcId Ref(:VPC)
    InternetGatewayId  Ref(:InternetGateway)
  }

  10.times do |i|
    subnet = "subnet#{i}"
    route_table = subnet + "RouteTable"
    route_table_assoc = route_table + "Assoc"

    Subnet(subnet) {
      VpcId Ref(:VPC)
      CidrBlock "10.1.#{i}.0/24"
      addTag("Name", "test vpc #{subnet}")
    }

    RouteTable(route_table) {
      VpcId Ref(:VPC)
      addTag("Name", route_table)
    }

    SubnetRouteTableAssociation(route_table_assoc) {
      SubnetId Ref(subnet)
      RouteTableId Ref(route_table)
    }

    Route(subnet + "GatewayRoute" ) {
      DependsOn :GatewayToInternet
      RouteTableId Ref(route_table)
      DestinationCidrBlock "0.0.0.0/0"
      GatewayId Ref(:InternetGateway)
    }
  end

}
