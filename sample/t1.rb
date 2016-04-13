CloudFormation do
  DESCRIPTION ||= 'default description'.freeze
  MACHINES ||= 1

  Description DESCRIPTION

  (1..MACHINES).each do |i|
    name = "machine#{i}"
    Instance(name) do
      ImageId 'ami-12345678'
      Type 't1.micro'
    end
  end
end
