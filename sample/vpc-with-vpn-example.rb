require 'cfndsl'

CloudFormation {
  Description "Creates an AWS VPC with a couple of subnets."

  Parameter("VPNAddress") {
    Type "String"
    Description "IP Address range for your existing infrastructure"
    MinLength "9"
    MaxLength "18"
    AllowedPattern "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})"
    ConstraintDescription "must be a valid IP CIDR range of the form x.x.x.x/x."
  }

  Parameter("RouterIPAddress") {
    Type "String"
    Description "IP Address of your VPN device"
    MinLength "7"
    MaxLength "15"
    AllowedPattern "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})"
    ConstraintDescription "must be a valid IP address of the form x.x.x.x"    
  }

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

  VPNGateway(:VirtualPrivateNetworkGateway) {
    Type "ipsec.1"
    addTag("Name", "Test VPN Gateway")
  }

  VPCGatewayAttachment(:VPNGatewayAttachment) {
    VpcId Ref(:VPC)
    VpnGatewayId Ref(:VirtualPrivateNetworkGateway)
  }

  CustomerGateway(:CustomerVPNGateway) {
    Type "ipsec.1"
    BgpAsn "65000"
    IpAddress Ref("RouterIPAddress")
    addTag("Name", "Test Customer VPN Gateway")
  }

  VPNConnection(:VPNConnection) {
    Type "ipsec.1"
    StaticRoutesOnly "true"
    CustomerGatewayId Ref(:CustomerVPNGateway)
    VpnGatewayId Ref(:VirtualPrivateNetworkGateway)
  }

  VPNConnectionRoute(:VPNConnectionRoute) {
    VpnConnectionId Ref(:VPNConnection)
    DestinationCidrBlock Ref("VPNAddress")
  }
}
