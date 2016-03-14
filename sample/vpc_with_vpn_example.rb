require 'cfndsl'

CloudFormation do
  Description 'Creates an AWS VPC with a couple of subnets.'

  Parameter('VPNAddress') do
    Type 'String'
    Description 'IP Address range for your existing infrastructure'
    MinLength '9'
    MaxLength '18'
    AllowedPattern '(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})'
    ConstraintDescription 'must be a valid IP CIDR range of the form x.x.x.x/x.'
  end

  Parameter('RouterIPAddress') do
    Type 'String'
    Description 'IP Address of your VPN device'
    MinLength '7'
    MaxLength '15'
    AllowedPattern '(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})'
    ConstraintDescription 'must be a valid IP address of the form x.x.x.x'
  end

  VPC(:VPC) do
    EnableDnsSupport true
    EnableDnsHostnames true
    CidrBlock '10.1.0.0/16'
    addTag('Name', 'Test VPC')
  end

  InternetGateway(:InternetGateway) do
    addTag('Name', 'Test VPC Gateway')
  end

  VPCGatewayAttachment(:GatewayToInternet) do
    VpcId Ref(:VPC)
    InternetGatewayId Ref(:InternetGateway)
  end

  10.times do |i|
    subnet = "subnet#{i}"
    route_table = subnet + 'RouteTable'
    route_table_assoc = route_table + 'Assoc'

    Subnet(subnet) do
      VpcId Ref(:VPC)
      CidrBlock "10.1.#{i}.0/24"
      addTag('Name', "test vpc #{subnet}")
    end

    RouteTable(route_table) do
      VpcId Ref(:VPC)
      addTag('Name', route_table)
    end

    SubnetRouteTableAssociation(route_table_assoc) do
      SubnetId Ref(subnet)
      RouteTableId Ref(route_table)
    end

    Route(subnet + 'GatewayRoute') do
      DependsOn :GatewayToInternet
      RouteTableId Ref(route_table)
      DestinationCidrBlock '0.0.0.0/0'
      GatewayId Ref(:InternetGateway)
    end
  end

  VPNGateway(:VirtualPrivateNetworkGateway) do
    Type 'ipsec.1'
    addTag('Name', 'Test VPN Gateway')
  end

  VPCGatewayAttachment(:VPNGatewayAttachment) do
    VpcId Ref(:VPC)
    VpnGatewayId Ref(:VirtualPrivateNetworkGateway)
  end

  CustomerGateway(:CustomerVPNGateway) do
    Type 'ipsec.1'
    BgpAsn '65000'
    IpAddress Ref('RouterIPAddress')
    addTag('Name', 'Test Customer VPN Gateway')
  end

  VPNConnection(:VPNConnection) do
    Type 'ipsec.1'
    StaticRoutesOnly 'true'
    CustomerGatewayId Ref(:CustomerVPNGateway)
    VpnGatewayId Ref(:VirtualPrivateNetworkGateway)
  end

  VPNConnectionRoute(:VPNConnectionRoute) do
    VpnConnectionId Ref(:VPNConnection)
    DestinationCidrBlock Ref('VPNAddress')
  end
end
