CloudFormation do
  description = external_parameters.fetch(:description, 'default description')
  machines = external_parameters.fetch(:machines, 1).to_i

  Description description

  (1..machines).each do |i|
    name = "machine#{i}"
    EC2_Instance(name) do
      ImageId 'ami-12345678'
      Type 't1.micro'
    end
  end
end
