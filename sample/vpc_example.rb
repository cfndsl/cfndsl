require 'cfndsl'

CloudFormation do
  Description 'Creates an AWS VPC with a couple of subnets.'

  VPC(:VPC) do
    EnableDnsSupport true
    EnableDnsHostnames true
    CidrBlock '10.1.0.0/16'
    add_tag('Name', 'Test VPC')
  end

  InternetGateway(:InternetGateway) do
    add_tag('Name', 'Test VPC Gateway')
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
      add_tag('Name', "test vpc #{subnet}")
    end

    RouteTable(route_table) do
      VpcId Ref(:VPC)
      add_tag('Name', route_table)
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
end
